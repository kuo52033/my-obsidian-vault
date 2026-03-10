### What is it

Sharding is a technique to ==**horizontally distribute data== across multiple machines**. Instead of storing everything in one database, data is split into smaller pieces (shards) and distributed across multiple nodes.

```
Without Sharding:
[ All Data ] → Single Machine (bottleneck)

With Sharding:
[ Data A-M ] → Shard 1
[ Data N-Z ] → Shard 2
[ Overflow ] → Shard 3
```

---

## Why Sharding

|Problem|Solution|
|---|---|
|Single machine storage limit|Distribute data across machines|
|Single machine query bottleneck|Queries go to specific shard only|
|Single point of failure|Each shard can have its own replica|

---

## Shard Key

The field used to decide which shard a piece of data goes to. **This is the most important design decision in sharding.**

```
// Example: sharding messages by roomId
roomId: "room_001" → hash → Shard 1
roomId: "room_002" → hash → Shard 2
roomId: "room_003" → hash → Shard 1
```

### Good Shard Key

- **High cardinality** — many unique values (userId, roomId)
- **Even distribution** — data spread evenly across shards
- **Query locality** — common queries hit one shard, not all

### Bad Shard Key

- **Low cardinality** — few unique values (status: active/inactive)
- **Hotspot** — most traffic goes to one shard (e.g. timestamp if most queries are for recent data)

---

## MongoDB Sharding

### Architecture

```
Client
  ↓
Mongos Router         ← Query router, decides which shard to hit
  ↓
Config Server         ← Stores shard metadata and chunk ranges
  ↓
┌─────────────────────────────────┐
│  Shard 1  │  Shard 2  │ Shard 3 │
│ (Replica  │ (Replica  │(Replica │
│   Set)    │   Set)    │  Set)   │
└─────────────────────────────────┘
```

### Sharded vs Unsharded Collections

```
Sharded Collection (messages — large data):
├── Shard 1 ── roomId A-M
├── Shard 2 ── roomId N-Z
└── Shard 3 ── overflow

Unsharded Collection (users — small data):
└── Primary Shard ── ALL data lives here (one machine)
```

**Unsharded collections live entirely on the Primary Shard** — one machine holds all the data.

### $lookup Limitation

```
✅ $lookup from unsharded collection → OK (same machine)
❌ $lookup from sharded collection   → Not supported or very slow
```

**Why:** $lookup across shards requires scatter-gather — querying all shards and merging results in memory. This is expensive and MongoDB does not recommend it.

### Solutions for Cross-Shard Joins

**Option 1: Embed data (preferred)**

```js
// Instead of referencing user by ID, embed what you need
{
  _id: "msg_1",
  text: "hello",
  sender: {
    id: "user_1",
    name: "John",       // ← duplicated, but no lookup needed
    avatar: "url..."
  }
}
```

Trade-off: data redundancy, must update all copies when user changes name.

**Option 2: Keep lookup target unsharded**

```
messages  → sharded   (large, needs distribution)
users     → unsharded (small, stays on Primary Shard)

$lookup from users → still works
```

Trade-off: unsharded collection becomes a bottleneck if it grows large.

**Option 3: Scatter-Gather (avoid if possible)**

```
Mongos broadcasts query to all shards
Each shard returns results
Mongos merges in memory → slow, expensive, risk of OOM
```

---

## SQL Sharding

SQL was not designed for horizontal sharding, making it harder than MongoDB.

### Application-Level Sharding (manual)

```js
const getShard = (userId) => userId % 3  // 0, 1, 2

const db = shards[getShard(userId)]
await db.query('SELECT * FROM messages WHERE user_id = ?', [userId])
```

**Problems:**

- Cross-shard JOINs must be done in application layer
- Cross-shard transactions are very complex
- Rebalancing shards when adding machines is painful

### Distributed SQL (modern approach)

Let the database handle sharding automatically:

|Database|Compatible With|Key Feature|
|---|---|---|
|CockroachDB|PostgreSQL|Auto sharding, cross-node transactions|
|PlanetScale|MySQL|Vitess underneath, zero-downtime migrations|
|TiDB|MySQL|HTAP (OLTP + OLAP), horizontal scale|

**These databases make sharding transparent to the application** — you write normal SQL, the database handles distribution.

---

## Handling Large SQL Data (Full Strategy)

From simplest to most complex:

```
1. Vertical Scaling
   └── Bigger machine (CPU, RAM, SSD)
       → Simple, but has physical limits and gets expensive

2. Read Replica
   └── Primary (writes) + Replicas (reads)
       → Good for read-heavy systems
       → Trade-off: eventual consistency on replicas

3. Caching (Redis)
   └── Cache hot queries in Redis
       → Reduces DB load significantly
       → Trade-off: cache invalidation complexity

4. Partitioning
   └── Split large table by time/range (same machine)
       └── e.g. messages_2024_01, messages_2024_02
       → Queries scan less data
       → Trade-off: transparent to app, but still single machine

5. Sharding
   └── Distribute data across multiple machines
       → True horizontal scale
       → Trade-off: complex, cross-shard operations are hard

6. CQRS (Command Query Responsibility Segregation)
   └── Writes → SQL (strong consistency)
       Reads  → MongoDB / Elasticsearch (optimised for queries)
       → Best performance per use case
       → Trade-off: data sync complexity, eventual consistency
```

---

## Trade-offs Summary

|Approach|Solves|Trade-off|
|---|---|---|
|Vertical Scaling|Simple capacity|Physical limit, expensive|
|Read Replica|Read throughput|Eventual consistency|
|Cache|Query load|Cache invalidation|
|Partitioning|Query performance|Still single machine|
|Sharding|Storage + throughput|Cross-shard complexity|
|Distributed SQL|Everything|Cost, learning curve|
|CQRS|Read performance|Sync complexity|

---

## Interview Answer Framework

> "When data grows too large for a single machine, I would approach it in layers:
> 
> First, add **Read Replicas** to handle read traffic and **Redis caching** to reduce DB load. Then use **partitioning** to improve query performance on large tables.
> 
> If that's still not enough, I'd consider **sharding** — for MongoDB this is relatively straightforward with Mongos routing, but for SQL I'd use a distributed SQL database like CockroachDB or TiDB to avoid managing sharding at the application level.
> 
> For read-heavy systems with complex query patterns, **CQRS** is worth considering — writes go to SQL for consistency, reads go to a NoSQL store optimised for the query pattern."

---

## Related Topics

- [[MongoDB]] — Embedded documents vs References, $lookup limitations
- [[Redis]] — Caching strategy, Cache invalidation
- [[System Design 通用框架]] — Capacity estimation, scaling decisions