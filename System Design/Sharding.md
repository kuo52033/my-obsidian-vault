### What is it

Sharding is a technique to ==**horizontally distribute== data across multiple machines**. Instead of storing everything in one database, data is split into smaller pieces (shards) and distributed across multiple nodes.

```
Without Sharding:
[ All Data ] → Single Machine (bottleneck)

With Sharding:
[ Data A-M ] → Shard 1
[ Data N-Z ] → Shard 2
[ Overflow ] → Shard 3
```

---

## When Do You Need Sharding

**Don't jump to sharding immediately.** First try read replicas and caching.

Signals that you need sharding:

- Write throughput consistently > 5,000/sec
- Storage > a few TB
- p99 latency consistently increasing
- CPU consistently > 70%

---

## 1. Partitioning Strategies

### Range-Based

Split data by attribute range (e.g. first letter, time, zip code).

```
A-M → Shard 1
N-Z → Shard 2
```

✅ Efficient for range queries 
❌ Uneven distribution, easy to create hot shards

---

### Hash-Based

```
Shard = Hash(key) % N
```

✅ Even distribution 
❌ Adding/removing nodes causes massive rehashing — almost all keys change their shard mapping

---

### Consistent Hashing (Modern Standard)

Solves the rehashing problem using a **Hash Ring + Virtual Nodes**.

```
Hash Ring (0 ~ 2^32):

  Node A → position 100
  Node B → position 200
  Node C → position 300

  Key K → hash(K) = 150 → find nearest node clockwise → Node B

Adding Node D (position 250):
  Only keys in range 200~250 (previously owned by C) move to D
  All other nodes unaffected ✓
```

**Virtual Nodes:** Each physical machine maps to 100-200 virtual positions on the ring.

- Distributes load more evenly (law of large numbers)
- When a node fails, its virtual segments transfer to different nodes — avoids overloading a single neighbour

Used by: ==**Cassandra, DynamoDB**==

---

## 2. Shard Key Design

The field used to decide which shard data goes to. **This is the most critical design decision.**

### Good Shard Key

- **High cardinality** — many unique values (userId, roomId)
- **Even distribution** — data spread evenly across shards
- **Query locality** — common queries hit one shard, not all

### Bad Shard Key

- **Low cardinality** — few unique values (e.g. status: active/inactive)
- **Hotspot** — most traffic concentrates on one shard (e.g. timestamp if queries are mostly recent data)

---

## 3. Composite Partition Key (Cassandra)

Single partition key causes unbounded growth on hot shards (e.g. a celebrity account with millions of tweets all on one node).

**Problem: Single user_id as partition key**

```
@elonmusk → 54,750 tweets over 15 years → all on the same node
That node gets hammered, others sit idle — defeats horizontal scaling
```

**Solution: Add a time bucket**

```sql
CREATE TABLE tweets (
  user_id    BIGINT,
  bucket     TEXT,      -- 'YYYY-MM', e.g. '2025-02'
  tweet_id   BIGINT,    -- Snowflake ID (time-sortable)
  content    TEXT,

  PRIMARY KEY ((user_id, bucket), tweet_id)
  --           ─────────────────  ────────
  --           Composite Partition Key    Clustering Key
  --           Determines target node     Determines sort order within node

) WITH CLUSTERING ORDER BY (tweet_id DESC);
```

|Part|Fields|Role|
|---|---|---|
|Composite Partition Key|`(user_id, bucket)`|`hash(user_id + bucket)` → target node|
|Clustering Key|`tweet_id`|Physical sort order within the node|

### Bucket Granularity Trade-offs

|Bucket|Posts/partition|Trade-off|
|---|---|---|
|Year `YYYY`|~3,650|Too large, heavy users still create hot shards|
|**Month `YYYY-MM`**|**~300**|**Recommended — bounded and efficient**|
|Week|~75|Too granular, querying 1 month needs 4+ queries|
|Day|~10|Too granular, most users post 1-2 times/day|

### Cross-Month Queries

```js
// Fetch latest 20 tweets spanning 2 months
// Fire parallel queries at application layer
const [feb, jan] = await Promise.all([
  query("SELECT FROM tweets WHERE user_id=123 AND bucket='2025-02' LIMIT 20"),
  query("SELECT FROM tweets WHERE user_id=123 AND bucket='2025-01' LIMIT 30")
])

// Merge and sort at application layer
return mergeAndSort([feb, jan]).slice(0, 20)
```

Key: application layer knows which buckets to query (usually last 1-2 months). Parallel execution keeps it fast.

---

## 4. Why Secondary Index Doesn't Solve Hot Shards

A common misconception: "Just add a secondary index on user_id."

Cassandra's secondary index is a **local index** — each node only indexes its own data:

```
Node 3 local index: user_id=123 → [tweet_A, tweet_D]
Node 7 local index: user_id=123 → [tweet_C, tweet_G]
...

Query WHERE user_id = 123:
→ Cassandra must ask ALL nodes "do you have user_id=123?"
→ Still full cluster scatter-gather
→ Same performance as no index
```

Cassandra's official docs explicitly warn: secondary indexes are only suitable for **low cardinality, low frequency** fields.

`user_id` = high cardinality (200M unique values) + high frequency → worst possible secondary index candidate.

---

## 5. Adaptive Bucketing (Advanced)

Fixed monthly buckets still create oversized partitions for extreme users (news accounts, bots).

Solution: dynamically adjust bucket granularity based on posting volume:

|Posts/month|Bucket strategy|Example|
|---|---|---|
|< 100|Year `YYYY`|`'2025'`|
|100 ~ 1,000|Month `YYYY-MM`|`'2025-02'`|
|1,000 ~ 5,000|Week `YYYY-Www`|`'2025-W08'`|
|> 5,000|Day `YYYY-MM-DD`|`'2025-02-23'`|

The User Service tracks each user's posting volume tier. The Tweet Service queries this before writing to choose the right bucket granularity. Trade-off: application layer needs to know which bucket strategy each user uses.

---

## 6. One Table Per Query Pattern (Cassandra Design Philosophy)

Cassandra's golden rule: **one query pattern = one table**. Intentional denormalization — trade space for time.

```sql
-- Table A: Query tweets by user (timeline, profile page)
CREATE TABLE tweets_by_user (
  PRIMARY KEY ((user_id, bucket), tweet_id)
);

-- Table B: Query tweet content by tweet_id (open single tweet, hydrate)
CREATE TABLE tweet_objects (
  PRIMARY KEY (tweet_id)
);

-- Write to BOTH tables on every insert (application layer responsibility)
-- Read from the table that matches your query pattern
```

**Timeline read flow:**

```
Step 1: Redis ZREVRANGE timeline:{uid}           → get 20 tweet_ids (fast)
Step 2: tweet_objects WHERE tweet_id IN [...]    → hydrate content

tweets_by_user → used when cache misses, to rebuild timeline in bulk
tweet_objects  → used to hydrate individual tweet content
```

This is not data redundancy — it is **intentional denormalization**, the standard design pattern in Cassandra.

---

## 7. MongoDB Sharding

MongoDB sharding is **transparent to the application layer** — handled automatically by the Mongos Router.

### Architecture

```
Client
  ↓
Mongos Router         ← You only talk to this. No routing logic in your code.
  ↓
Config Server         ← Stores shard metadata and chunk ranges
  ↓
┌──────────┬──────────┬──────────┐
│  Shard 1 │  Shard 2 │  Shard 3 │
│(Replica  │(Replica  │(Replica  │
│  Set)    │  Set)    │  Set)    │
└──────────┴──────────┴──────────┘
```

### Application Code Doesn't Change

```js
// You just write normal queries
// Mongos automatically routes to the correct shard
await db.messages.findOne({ roomId: "room_123" })

// You do NOT need:
// const shard = hash(roomId) % 3
// const db = shards[shard]
```

### Setup: Just Define the Shard Key Once

```js
sh.shardCollection("mydb.messages", { roomId: "hashed" })
// After this, MongoDB handles distribution, routing, and rebalancing automatically
```

### Sharded vs Unsharded Collections

```
Sharded Collection (messages — large data):
├── Shard 1 ── roomId A-M
├── Shard 2 ── roomId N-Z
└── Shard 3 ── overflow

Unsharded Collection (users — small data):
└── Primary Shard ── ALL data lives on one machine
```

### $lookup Limitation

```
✅ $lookup from unsharded collection → OK (same machine, no cross-shard)
❌ $lookup from sharded collection   → Not supported or extremely slow
```

**Why:** cross-shard $lookup requires scatter-gather — query all shards, merge results in Mongos memory. Expensive and risks OOM.

### Solutions for Cross-Shard Joins

**Option 1: Embed data (preferred)**

```js
{
  _id: "msg_1",
  text: "hello",
  sender: {
    id: "user_1",
    name: "John",      // ← duplicated, but no lookup needed
    avatar: "url..."
  }
}
```

Trade-off: data redundancy, must update all copies when user changes info.

**Option 2: Keep lookup target unsharded** Keep small, rarely-written collections (like `users`) unsharded on the Primary Shard. $lookup against them still works. Trade-off: becomes a bottleneck if the unsharded collection grows large.

**Option 3: Scatter-Gather (avoid)** Mongos broadcasts to all shards, merges in memory. Slow, expensive, OOM risk.

---

## 8. ID Generation and the Routing Deadlock

**The deadlock:**

```
Web Server needs ID first → to compute Hash(ID) % N → to decide which shard to write to
But DB auto-increment requires a DB connection → no ID before connecting → can't route
```

### MongoDB ObjectID (Client-Side)

```
[ 4 bytes Unix timestamp (seconds) ][ 5 bytes random ][ 3 bytes counter ]
```

- Generated in memory, no DB round-trip
- Timestamp precision: seconds — cross-machine ordering within same second not guaranteed

### Snowflake ID (Twitter, 64-bit)

```
[ 41-bit millisecond timestamp ][ 10-bit machine ID ][ 12-bit sequence ]
```

- Millisecond precision, globally sortable
- 8 bytes (33% smaller than ObjectID)
- Generated in memory in ~1 microsecond
- Machine ID assigned once at startup by ZooKeeper — zero coordination at runtime

### Modern SQL Solutions

- **Middleware** (Vitess, Apache ShardingSphere): proxy layer handles ID generation and routing, app sees one giant MySQL
- **Distributed SQL** (TiDB `AUTO_RANDOM`, CockroachDB UUID): database handles routing internally, full SQL + ACID preserved

---

## 9. SQL vs NoSQL Sharding

||SQL (MySQL)|MongoDB|Cassandra / DynamoDB|
|---|---|---|---|
|Sharding|Manual (application layer)|Automatic (Mongos)|Automatic (built-in)|
|Cross-shard JOIN|Must do in application layer|$lookup limited|Design to avoid|
|Routing logic|In your code|Mongos handles it|Driver handles it|
|Schema design|Flexible|Flexible|Must match query pattern upfront|
|Rebalancing|Painful|Automatic|Automatic|

---

## 10. Scaling Strategy (Full Picture)

Apply in order — don't jump to sharding prematurely:

```
1. Vertical Scaling
   └── Bigger machine (CPU, RAM, SSD)
   ✅ Simple, no code changes
   ❌ Physical limit, expensive

2. Read Replica
   └── Primary (writes) + Replicas (reads)
   ✅ Good for read-heavy systems
   ❌ Eventual consistency on replicas

3. Caching (Redis)
   └── Cache hot queries in Redis
   ✅ Dramatically reduces DB load
   ❌ Cache invalidation complexity

4. Partitioning
   └── Split large table by range/time (same machine)
   ✅ Transparent to application, faster queries
   ❌ Still single machine

5. Sharding
   └── Distribute data across multiple machines
   ✅ True horizontal scale
   ❌ Cross-shard operations are hard

6. CQRS
   └── Writes → SQL (strong consistency)
       Reads  → NoSQL (optimised for query pattern)
   ✅ Best performance per use case
   ❌ Data sync complexity, eventual consistency
```

---

## 11. Common Sharding Problems

|Problem|Cause|Solution|
|---|---|---|
|Hot shard|Bad shard key, low cardinality|Composite key + bucket|
|Cross-shard JOIN|Data on different nodes|Embed data, or denormalize|
|Cross-shard transaction|No global ACID|Two-phase commit, or eventual consistency design|
|Rebalancing pain|Hash-based sharding|Consistent Hashing|
|Scatter-gather|No partition key in query|Always query with partition key|

---

## 12. Queries Cassandra Cannot Do (Don't Try)

```sql
-- ❌ Full text search: requires full cluster scan
SELECT * FROM tweets WHERE user_id = 123 AND content LIKE '%hello%'

-- ❌ Cross-user aggregation: no global index
SELECT COUNT(*) FROM tweets WHERE created_at > '2025-01-01'

-- ❌ Query without partition key: Cassandra rejects it
SELECT * FROM tweets WHERE bucket = '2025-02'
```

Use **Elasticsearch** for full-text search and **Analytics DB / Data Warehouse** for aggregations.

---

## Interview Answer Framework

**"When data grows too large for a single machine..."**

> "I'd approach it in layers. First, add Read Replicas to offload read traffic and Redis caching to reduce DB load. Then use partitioning to improve query performance on large tables.
> 
> If that's still not enough, I'd consider sharding. For MongoDB, the Mongos Router handles routing automatically — I just define the shard key. For SQL, I'd use a distributed SQL database like CockroachDB or TiDB rather than managing sharding at the application level.
> 
> For Cassandra-style systems, the most important decision is the Partition Key — it must match the most common query pattern. If the key causes hot shards, I'd use a Composite Partition Key with time buckets to bound partition size."

**"How do you choose a shard key?"**

> "First I identify the most common query patterns. The shard key must match those patterns to avoid scatter-gather. It needs high cardinality for even distribution, and should keep related data on the same node so queries don't cross shards."

> **Interview tip:** When asked about sharding, always start with "first I need to understand the query patterns." This shows you understand the design philosophy, not just the mechanics.

---

## Related Topics

- [[MongoDB]] — Embedded documents vs References, $lookup limitations
- [[Redis]] — Caching strategy, Cache invalidation
- [[Cassandra]] — Partition key design, clustering key, denormalization
- [[System Design 通用框架]] — Capacity estimation, scaling decisions