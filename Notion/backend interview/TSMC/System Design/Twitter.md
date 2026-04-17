---
notion-id: 30f5a6e2-1812-8092-ad69-dae69c725e22
---
1. Requirements Clarification
    1. functional
        1. post tweets (text, photos, viedo)
        2. follow/unflollow users
        3. user timeline (feed)
        4. mark favorites
        5. search tweets
    2. non-functional
        6. high availability (99.99%)
        7. timeline latency < 200ms
        8. eventual consistency ok (AP in CAP theorem)
        9. read-heavy worload
        10. global scale
2. System API Definition
POST /v1/tweets ( rate limited: 300 tweets/3hr per user)
```json
//body
{text, media_ids[],location, reply_to_id}
//response
{tweet_id, created_at, url}
```
GET /v1/timeline/:user_id?cursor=&limit=20&type=home|user
```json
//response
{tweets[], next_cursor}
```
POST /v1/user/:user_id/follow
```json
//body
{target_user_id}
```
POST /v1/tweets/:tweet_id/favorite
GET /v1/search?q=&type=recent|popular&cursor=

- **Back-of-the-Envelope Estimation**
    - Assumptions: 1B total users, 200M DAU, 100M tweets/day, avg 200 follows/user
        - writes/sec: 100M **÷** 86400 = 1157 tweets/sec
        - reads/sec: 200M users x 20 tweets ( each pages) x 7 views **÷** 68400 = 325000 reads/sec
        - read : write ratio 280: 1
        - storage - text: 300 bytes (each tweet) x 100M = 30 GB/day, 5 years: 30GB x 365 x 5 = 54 TB
        - storage - media
            - 20M photo/day, 200 KB/photo: 4 TB/day
            - 10M videos/day, 2 MB/video: 20 TB/day
            - total: 24 TB/day
        - Bandwidth
            - Ingress:  24 TB **÷** 86400 = 290 MB/s incoming
            - Egress
                - Text: 28B tweets/day x 280 bytes/tweet ÷ 86400 = 93 MB/s
                - Photo: 28B ÷ 5 (photo) x 200KB ÷ 86400 = 13 GB/s
                - Video: 28B ÷ 10 ( video) x 2MB ÷ 86400 = 60 GB/s
                - total: 70 GB/s outbound
- Data Model
    - User { user_id, username, email, created_at, follower_count (denormalized)
    - Tweet { tweet_id, user_id, content, meda_ids, reply_to_id, created_at, like_count}
    - Follow { follower_id, followee_id, created_at}
    - Timeline (pre-computed, in Redis) { key: “timeline:{user_id}”, value, size:800}
- Database Selection
| Layer | Choice | Why |
| --- | --- | --- |
| User Profile | PostgresSQL | Write volume id tiny, need ACID, need complex queries |
| Tweets | Cassendra | write-heavy (write in-memory first, then flushed to disk), linear horizontal scaling, no resharding pain <br>trade-off: ❌No joins, ❌No transactions across partitions, ❌ Eventual consistency |
| Social Graph (follows) | Cassendra+Redis | Cassandra stores the raw follow relationship, Redis stores hot folow sets for fast lookups o(1) |
| Timeline | Redis cluster | stores an ordered list of the 800 most recent tweet_ids from people thet follow, you;d need 1300 Cassandra node just for timline reads, with Redis 90% cheaper |
| Media | S3-compatible object store | Object store: optimized for storing and retrieving large binary blobs, infinite scale, 99.999999% durability, native CDN integration |
| Search  | Elasticsearch | Inverted index of tweet content, hashtags, user mentions, why not Cassendra, LIKE '%climate change%’ will cause full tabe scan |

### High-Level Architecture

![[螢幕擷取畫面_2026-02-22_145438.png]]

- API Gateway - front door security + reception desk
    - Are you allowed in?
    - What service do you need to go?
    - How many times can you visit today?
    - Responsibility
        - Authentication & Authorization ( JWT token or OAuth token): Gateway validates token ONCE before request reached any service.
        - Rate Limiting: A single script can span 1M requests/sec, crashed your backend, Dos attack
        - Request Routing: The gateway figures out which internal mivroservice handles it.
        - SSL/TLS Termination: TLS encrytion/decryption is CPU-expensive, doing it once at the edge is much cheaper and internal network is private/trusted
        - Request/Response Transformation: Gateway transforms the response → smaller payload → faster mobile load. No need to change the Tweet Service for each client type.
        - Observability Entry Point: Every single request passes through the gateway, making it the perfect place to collect metrics uniformly.
- Load Balancer - Traffic Director
    - Once the API Gateway has approved and routed a request to the right service, the Load Balancer answers: **which specific instance of that service handles it?**
    - API Gateway → (this request goes to Tweet Service) → load balancer → (Tweet Service has 20 insatnces unning, lb pick one service)
    - Algorithm
        - Round Robin: simple zero overhead, fair distribution
        - Least Connections: Always send to the server with fewest active connections
        - Weighted Round Robin: Not all servers are equal.
        - IP hash/ Sticky Sessions: Same user always goes to the same server, used when server hold session state in memory or websocket connections
    - The Critical Feature - Health checking
        - Every 5 seconds:
GET [http://tweet-service-04/health](http://tweet-service-04/health)
Expected: 200 OK { "status": "healthy", "db": "connected" }
    - The architecture has three distinct layers
```json
LAYER 1 — Between Client and API Gateway
─────────────────────────────────────────
  Purpose: Distribute incoming internet traffic across gateway instances
  Type:    L4 (Network) load balancer — works at TCP level
  Tool:    AWS NLB, Cloudflare, or hardware (F5) at edge
  Why L4?: Fastest possible, before TLS termination even happens
           Handles millions of connections/sec

           Client
             │
    ┌────────┼────────┐
    ▼        ▼        ▼
  GW-01   GW-02   GW-03    (API Gateway instances)


LAYER 2 — Between API Gateway and Microservices
────────────────────────────────────────────────
  Purpose: Route to correct service instances
  Type:    L7 (Application) load balancer — understands HTTP
  Tool:    AWS ALB, Nginx, Envoy, Traefik
  Why L7?: Can route based on URL path, headers, cookies
           Can inspect request content for smarter routing

           API Gateway
                │
       ┌────────┼────────┐
       ▼                 ▼
  Tweet Service    Timeline Service
  (instances 1-20) (instances 1-15)


LAYER 3 — Between Services and Databases
─────────────────────────────────────────
  Purpose: Route reads to replicas, writes to primary
  Type:    Specialized DB proxy
  Tool:    ProxySQL (MySQL), PgBouncer (Postgres), Envoy
  Why?:    Automatically separates read vs write traffic
           Connection pooling (prevent DB connection exhaustion)
           Seamless failover when primary dies

           Tweet Service
                │
       ┌────────┴────────┐
       ▼                 ▼
  Primary DB        Read Replicas
  (writes only)     (reads only, 3-5 replicas)
```
Together: Gateway decides the request is valid and which service
handles it. Load Balancer decides which instance of
that service does the actual work.

### The Fan-out Problem

When user A (with 1M followers) posts a tweet, how do followers see it?

- Hybrid fan-out. Regular users get push (pre-computed timelines in Redis). Accounts with >1M followers use pull at read time. The threshold is tunable.

### Detailed Design

- Tweet ID Generation - Snowflake IDs
- Timeline Generation Flow
    - challenge
        - follow 500 people
        - Each posts multiple times a day
        - see latest tweets in < 200ms
        - 200M users all doing this simultaneously
    - Write Path - someone posts a tweet
        - You type “hellow world” → post
        - hits API Gateway → validates JWT token → extracts user_id=123 → checks rate limit → route to Tweet Service
        - Generates Snowflake ID → validate content → Persists to Cassendra → returns 200 OK  ( Job done on the synchronous path )
        - Publishes event to Kafka (async)
            - Kafka topic: “tweet-created”
            - Message: { tweet_id, user_id, media_id }
        - Fan-out workers consume event, receives for user_id and tweet_id → get following user_id from Redis → check follower_count > 1M →[TRUE] SKIP fan-out (celebrity mode)
        - [FALSE] write tweet_id into each follower’s timeline cache → ZADD timeline:　{follower_id} {tweet_id_score} {tweet_id} (Sorted Set in Redis, scored by time) 
        - Parallel side effects → Search indexer ( elsticsearch) / Notification Svc / Analytics Svc 
    - Read Path - someone open Twitter
        - hits API Gateway → validates JWT token → routes to Timeline Service → Fetched tweet IDs from Redis  → ZREVRANGE timeline:456 0 19 ( returns up to 20 tweet_ids, newest first from user_id 456)
            - Cache Hit ( Happy path, ~95% of requests)
            - Cache MISS (new user, inactive user, cache evicted)
                - Fetch list of user 456 follows from Redis → for each followee, query Cassendra for their recent tweets → merge all results → take top 20 → store in Redis
        - Fetch autual content ( In Redis or Cassendra)
        - Handle celebrity tweets → Fetch celebrtity last 20 tweets from their tweet cache → merge celebrity tweets with regular timeline
        - return response
```json
  {
    tweets: [
      {
        tweet_id:    "6985444736544108546",
        content:     "Hello world",
        author: {
          user_id:   123,
          username:  "johndoe",
          avatar:    "https://cdn.twitter.com/avatars/123.jpg"
        },
        like_count:  42,
        created_at:  "2025-02-23T10:00:00Z",
        media: []
      },
      ... (19 more)
    ],
    next_cursor: "6985444736544107100"  ← ID of last tweet shown
  }
```
The Full Picture
```json
WRITE PATH (async, non-blocking)
─────────────────────────────────────────────────────────────────────
  You post tweet
       │
       ▼
  Tweet Service ──saves to──→ Cassandra (durable storage)
       │
       └──publishes──→ Kafka "tweet-created"
                            │
              ┌─────────────┼─────────────┐
              ▼             ▼             ▼
        Fan-out        Search          Notification
        Worker         Indexer         Service
              │
              ▼
        For each follower:
        ZADD timeline:{id} in Redis
        (skips celebrities > 1M followers)

READ PATH (sync, must be fast)
─────────────────────────────────────────────────────────────────────
  You open Twitter
       │
       ▼
  Timeline Service
       │
       ├──→ Redis: ZREVRANGE timeline:{you}    (~0.5ms)
       │           get 20 tweet_ids
       │
       ├──→ Redis: MGET tweet:{id} × 20        (~1ms)
       │           get tweet objects
       │
       ├──→ [parallel] Celebrity tweets         (~5ms)
       │    fetch from hot cache
       │
       ├──→ Redis: MGET user:{id} × authors    (~1ms)
       │           get user profiles
       │
       └──→ [optional] ML ranking model        (~30ms)
                        re-rank by relevance

       Total: ~50ms (cache hits)
              ~150ms (cache misses)
              200ms SLA → met ✓
```

### Cacheing Strategy

| What | Cache Layer | TTL | Eviction |
| --- | --- | --- | --- |
| Timeline (tweet_ids) | Redis Sorted Set | No expiry (LRU on size cap) | ZREMRANGEBYRANK (trim to 800) |
| Tweet objects | Redis Hash | 7 days | LRU (20% of daily volume) |
| User profiles | Redis / CDN edge | 5 min | LRU |
| Follow graph | Redis Set | 1 hour | LRU |
| Media (photos/video) | CDN (CloudFront) | Immutable (1 year) | Manual invalidation |

### Data sharding for tweets

Use a composite partition key: `(user_id, tweet_bucket)` where bucket = month/year. This prevents hot partitions while keeping per-user time-range queries efficient.

### Bottlenecks

3. Hot Users
    1. someone has 150M follers, when he posts a tweet will stuck the Redis
    2. Fix: Define a threshold
        1. if user.follower_count ≤ 1M → PUSH: fan out tweet_id to all followers timelines in Redis
        2. id user.follower_count > 1M → SKIP fan-out, their tweets fetched at READ time instead
4. Thundering Herd
    3. When a tweet goes viral, lead to another tweet in Redis be evicted (LRU), and this tweet is in  50M people’s timeline, meanwhile all those requests to Cassendra are rebuilding the same cache entry.
    4. Fix1 : Mutex lock on Cache rebuild, only one request is allowed to query the DB, all other requests wait for that one to finish.
    5. Fix2 : CDN ad First Line to Defense, request → CDN → Redis → Cassandra
5. Write Spikes
    6. Normal Load: 1150 tweets/sec, but In New Year Eve: 15000+ tweets/sec 
    7. without protection: Tweet Service CPU 100 → requests fail → return 503 or write latency climbs from 5ms → 500ms → 5000ms
    8. Fix1: Kafka as write buffer
        3. Without buffer: Client → Tweet Service → Cassandra ( synchronous , at higher write ratio Cassandra will overwhelm.)
        4. With Kafka: Client → Tweet Service → Kafka ( synchronous, but very fast ) → Cassandra consumer (pulls from Kafka at steady 50k/sec ) 
    9. Fix2: Auto-scaling, k8s Horizontal pod autoscaler (HPA)
        5. Normal running 10 pods → spike detected ( if CPU > 70% for 60 seconds ) → scale to 50 pods in 2 min
        6. if 2 minutes is slow for a sudden spike, we can use predictive scaling, don’t wait for CPU alart - scale before the spike

### Fault Tolerance

6. Database Node failure
    1. DB cluster: 100 nodes, Replication Factor = 3 ( each piece of data exists on 3 different node.)
    2. Consistency Levels control the trade-off
        1. with QUORUM: Must confirm on 2 of 3 nodes in globally before return success 
        2. with LOCAL_QUORUM: Must confirm on 2 of 3 nodes in one data center.
        3. with ANY: accept 1 node confirmation
        4. with LOCAL_ONE:  accept 1 node confirmation in one data center.
7. Redis Cache Failure
    3. When redis cluster node fails, with cache miss user will hit Cassandra directly, maybe cause Cassandra overwhelmed.
    4. Fix: Redis Cluster with Replication, 6 nodes total( 3 primary, 3 replica), when primary 1 fails, Promotes Replica 1 to new Primary 1 automatically and traffic resumes in 30 seconds. During 30 second failover, read served from replica, writes to queue and retried after promotion
8. API Gateway/ Load Balance Failure
    5. if API Gateway or Load Balance goes down, all requests from client will fail.
    6. Fix1: Active-Active Redundancy, run 10+ gateway instances across 3 availability zones. DNS use anycast routing, multiple IP addresses for twitter.com, client connects to nearest healthy gateway.
    7. Fix2: Active-passive pair, primary LB handle traffic, standby LB monitors primary via heartbeat.
9. Entire Datacenter Goes down
    8. AWS us-east-1 has a major outage. All services in that region go dark.
    9. Fix: Active-Active Multi-Region, Twitter runs in 3 regions simultaneously. Each Region has full Cassandra cluster, Redis Cluster and application service fleet
