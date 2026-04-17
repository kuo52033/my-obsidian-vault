---
notion-id: 3105a6e2-1812-815a-a00d-d344b44689d3
---
# ID Generation in Distributed Systems

> **Goal:** Pick the right ID strategy for your scale. Every choice has a ceiling — know where yours is.

---

## The Core Problem

Every system needs unique IDs. The question is **who generates them** and **how**.

Three constraints pull in different directions:

- **Uniqueness** — no two records share an ID, ever
- **Speed** — generation can't become a bottleneck
- **Order** — IDs should reflect insertion time for efficient queries

No single strategy wins all three at every scale. That's why you need to know all of them.

---

## Strategy 1: AUTO_INCREMENT

**How it works**

Database owns a counter. Every INSERT bumps it by 1 and returns the new value.

```javascript
App Server → INSERT INTO tweets (content) VALUES ('hello')
Database   → counter++ → returns id = 12346
App Server ← { tweet_id: 12346 }
```

**What's good**

- Dead simple — zero extra code or infrastructure
- Perfect sequential ordering — id 5 always came before id 6
- Tiny storage — 4 bytes (INT) or 8 bytes (BIGINT)
- Excellent B-tree index performance (sequential inserts = no page splits)

**What breaks at scale**

- **Lock contention** — the counter needs a mutex; at 5,000 writes/sec, requests queue up waiting for that lock
- **Single point of failure** — counter DB goes down = zero writes, system-wide
- **Cannot distribute** — two DBs both auto-incrementing from 1 = ID collisions immediately
- **Ceiling is hard** — vertical scaling (bigger machine) only goes so far

**The odd/even hack** (real workaround used at medium scale)

```javascript
DB-A: increment=2, offset=1 → generates 1, 3, 5, 7...
DB-B: increment=2, offset=2 → generates 2, 4, 6, 8...

Works for 2 nodes. Adding a 3rd requires reconfiguring everything.
Maxes out around 10 nodes before becoming unmanageable.
```

**Use when:** single-region app, writes < 1,000/sec, downtime of minutes is tolerable

---

## Strategy 2: MongoDB ObjectID

**How it works**

The MongoDB driver generates a 12-byte ID **inside the application process** — no DB round trip needed.

```javascript
_id: ObjectId("64b5f3a2 3f8b2c 1d4e 8a9f12")
              ────────  ──────  ────  ──────
              4 bytes   3 bytes 2 b   3 bytes
              UNIX TIME RANDOM  PID   COUNTER
```

**Byte breakdown**

| Bytes | Content | Detail |
| --- | --- | --- |
| 1–4 | Unix timestamp | Seconds since epoch (not ms) |
| 5–7 | Random value | Unique per machine/process |
| 8–9 | Process ID | Differentiates mongod processes on same host |
| 10–12 | Counter | Starts random, increments per insert |

**What's good**

- Generated in-process — no network call, no DB bottleneck
- Embeds creation time — `ObjectId.getTimestamp()` returns the date instantly
- Works across machines without coordination
- Automatic in MongoDB — zero configuration

**What's limited**

- **Second-level precision only** — timestamp stores seconds, not milliseconds
- **Not reliably ordered across machines** — within the same second, ordering depends on per-process counters which are not globally synchronized
- **Larger than needed** — 12 bytes vs 8 bytes for Snowflake; at billions of documents, this adds up to hundreds of GB of extra index RAM

**The 1-second problem visualized**

```javascript
Machine A inserts Tweet X at 10:00:00.100 → counter = 500
Machine B inserts Tweet Y at 10:00:00.900 → counter = 12

Sorted by _id: Tweet Y appears BEFORE Tweet X
Even though Tweet X was inserted earlier.

Within 1 second, cross-machine order is broken.
```

**Use when:** MongoDB-based app, writes < 10,000/sec, second-level ordering is acceptable

---

## Strategy 3: Snowflake ID

**How it works**

A 64-bit integer generated **in application memory**. No DB. No network. Pure bit manipulation.

Twitter invented this in 2010. Discord, Instagram, and most large platforms use variants of it today.

**The 64-bit layout**

```javascript
┌──────────────────────────────┬──────────────┬────────────────┐
│          41 bits             │   10 bits    │    12 bits     │
│        TIMESTAMP             │  MACHINE ID  │   SEQUENCE     │
│  milliseconds since epoch    │  worker node │  counter/ms    │
└──────────────────────────────┴──────────────┴────────────────┘
Bit 63 (sign bit) always = 0 → keeps number positive
```

**Part 1 — Timestamp (41 bits)**

```javascript
Stores milliseconds since a custom epoch.
Twitter's epoch: November 4, 2010

2^41 = 2,199,023,255,552 ms = 69.7 years of runway
Valid until ~2079 from Twitter's epoch.

Key property: timestamp is the LEFTMOST bits
→ bigger timestamp = bigger ID, always
→ ORDER BY tweet_id = ORDER BY created_at, no extra index needed
```

**Part 2 — Machine ID (10 bits)**

```javascript
2^10 = 1,024 unique worker nodes
Split as: [5 bits datacenter][5 bits worker] = 32 DCs × 32 workers

Assigned ONCE at startup via ZooKeeper or config file.
Never changes during runtime.
Two workers with different IDs → IDs can never collide,
even at identical timestamp and sequence.
```

**Part 3 — Sequence (12 bits)**

```javascript
2^12 = 4,096 unique values per millisecond per worker

Starts at 0 each millisecond, increments per ID.
If 4,096 IDs generated in same ms → wait for next ms.
Resets to 0 on new millisecond.

Capacity: 4,096 IDs/ms × 1,000 ms = 4,096,000 IDs/sec per worker
Twitter peak need: ~5,000/sec total. One worker handles it easily.
```

**ID assembly (code)**

```python
def generate(self):
    now = current_ms() - CUSTOM_EPOCH
    
    if now == self.last_timestamp:
        self.sequence = (self.sequence + 1) & 4095
        if self.sequence == 0:          # overflow
            while now <= self.last_timestamp:
                now = current_ms() - CUSTOM_EPOCH
    else:
        self.sequence = 0               # new ms, reset
    
    self.last_timestamp = now
    
    return (now << 22) | (self.worker_id << 12) | self.sequence
```

**Extracting time from any ID**

```python
created_ms = (tweet_id >> 22) + CUSTOM_EPOCH
# Shift off the 10 machine bits + 12 sequence bits → just timestamp remains
# O(1), no DB query needed
```

**What's good**

- Generated in-process — ~1 microsecond, 1,000× faster than DB round trip
- Millisecond precision — correct ordering even at 5,000 inserts/sec
- Guaranteed unique across all machines — machine ID bits make it impossible to collide
- Compact — 8 bytes, fits in BIGINT, B-tree friendly
- Zero coordination at runtime — ZooKeeper only needed at startup
- Survives DB outages — ID generation never stops

**What to watch**

- **Clock skew** — if server clock moves backward, must pause generation until clock catches up
- **Worker ID management** — need ZooKeeper or config system to assign worker IDs at startup (minor operational overhead)
- **Not truly random** — IDs are guessable/sequential; don't expose raw Snowflake IDs in public URLs if you want to hide counts

**Use when:** distributed system, writes > 1,000/sec, millisecond ordering required, multi-region

---

## Comparison Table

| Property | AUTO_INCREMENT | MongoDB ObjectID | Snowflake ID |
| --- | --- | --- | --- |
| Size | 4–8 bytes | 12 bytes | 8 bytes |
| Generated by | Database | App driver | App server |
| Network round trip | Yes, every time | No | No |
| Time precision | N/A (sequential) | 1 second | 1 millisecond |
| Cross-machine unique | No (naive) | Mostly yes | Guaranteed |
| Survives DB outage | No | Yes | Yes |
| Max throughput | ~50K/sec | ~500K/sec | ~4B/sec |
| Operational overhead | None | None | Worker ID setup |
| Use at Twitter scale | ✗ | ✗ | ✓ |

---

## When to Switch

```javascript
Writes/sec    Strategy
──────────────────────────────────────────
< 500         AUTO_INCREMENT — keep it simple
500 – 5K      AUTO_INCREMENT with read replicas, or ObjectID
5K – 50K      Snowflake, or ObjectID if using MongoDB
50K+          Snowflake — non-negotiable
```

---

## Modern Alternatives (2025)

**ULID** (Universally Unique Lexicographically Sortable ID)

```javascript
01ARZ3NDEKTSV4RRFFQ69G5FAV
├─────────────┤├────────────┤
  48-bit time   80-bit random
  ms precision  no worker ID needed

Pros: no worker coordination, string-safe (base32), 128-bit
Cons: larger than Snowflake, slight collision risk (random component)
Use when: you want Snowflake benefits without worker ID management
```

**UUIDv7** (2022 RFC standard)

```javascript
018e3af3-6c80-7000-8000-000000000000
├────────────────┤├──────────────────┤
  48-bit Unix ms   random + version bits

Pros: standard RFC, widely supported, ms-sortable
Cons: 128-bit (16 bytes), larger index footprint
Use when: you need a cross-language standard with time ordering
```

---

## The Core Insight

> AUTO_INCREMENT guarantees uniqueness through **coordination** — asking a central authority for the next number.

> Snowflake guarantees uniqueness through **structure** — encoding time + machine + sequence into the number itself.

> At small scale, coordination is cheap → AUTO_INCREMENT wins (simpler).

> At large scale, coordination is a bottleneck → Snowflake wins (faster, more resilient).

> The switch point is roughly **1,000–5,000 writes/sec**. Below that line, simplicity wins. Above it, structure wins.