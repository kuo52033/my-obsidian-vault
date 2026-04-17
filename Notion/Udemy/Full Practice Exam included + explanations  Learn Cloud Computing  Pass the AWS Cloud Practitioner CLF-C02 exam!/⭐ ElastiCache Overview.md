---
notion-id: 2b55a6e2-1812-804e-a8fe-dc4b55cb10cd
---
## What is ElastiCache?

Amazon ElastiCache is a **fully managed in-memory database** service.

It provides two engines:

- **Redis**
- **Memcached**

Think of it as *“RDS for in-memory caching systems.”*

---

## Why Use ElastiCache?

ElastiCache is designed for:

- **Ultra-low latency reads**
- **High throughput**
- **Offloading read pressure from your main database**
- **Caching frequently accessed data**

If an exam question mentions **in-memory**, **microseconds-level latency**, or **cache**, the answer is almost always **ElastiCache**.

---

## Benefits (Managed by AWS)

- OS maintenance & patching
- Automatic failover (Redis)
- Monitoring & metrics
- Setup & configuration
- Failure recovery
- Backup & restore options

You don’t manage servers — AWS does.

---

## How ElastiCache Improves Architecture

### ❌ Without Cache

All reads go directly to your RDS database ⇒

Higher latency, increased load, potential bottlenecks.

### ✔ With ElastiCache

```latex
flowchart LR
    User --> ELB --> EC2
    EC2 -->|Read/Write| RDS
    EC2 -->|Cached Reads (Fast)| Cache[(ElastiCache)]
```

- Frequently accessed queries stored in **ElastiCache**
- Application checks cache first → **microsecond response**
- Database load reduced significantly

This improves:

- Performance
- Scalability
- Cost efficiency

---

## Typical Use Cases

- Session storage
- Leaderboards
- Caching database query results
- Gaming and real-time apps
- Rate limiting
- Token storage / authentication data
- E-commerce product catalog caching

---

## Exam Tips

- **“In-memory” → ElastiCache**
- **“Reduce RDS load” → ElastiCache**
- **“Low latency reads” → ElastiCache**
- **Redis = richer features** (pub/sub, persistence, sorted sets)
- **Memcached = simple, fast, scalable cache layer**