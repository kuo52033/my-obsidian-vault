---
notion-id: 2cb5a6e2-1812-8026-b84f-d51e08be4522
---
**AWS Well-Architected Framework – CLF-002**

---

## 🎯 Definition (Exam-friendly)

**Performance Efficiency** = using **compute resources efficiently** to meet requirements **now**, and staying efficient as **demand changes** + **technology evolves**.

---

## 🧱 Design Principles (Must Remember)

### 1) Democratize Advanced Technologies

- Adopt managed/advanced services when they become available
- Track new AWS capabilities (faster + less ops overhead)

### 2) Go Global in Minutes

- Multi-Region deployments should take **minutes**, not days
- Use **Infrastructure as Code** (e.g., CloudFormation)

### 3) Use Serverless Architectures

- “Golden state” for efficiency: **no server management**
- Automatic scaling by default (Lambda, managed services)

### 4) Experiment More Often

- Prototype alternative architectures (e.g., move to serverless)
- Validate performance at 10x load early

### 5) Mechanical Sympathy

- Know how services behave (limits, latency, caching, storage types)
- Pick services that match workload patterns

---

## 🧰 Service Selection (CLF-002 Quick Map)

Choose the right tool for the right scaling/perf pattern:

| Need | Typical AWS Choice |
| --- | --- |
| Auto scale compute fleet | **Auto Scaling (EC2)** |
| Serverless compute | **Lambda** |
| Block storage performance tuning | **EBS** (gp / io classes) |
| Global object storage scaling | **S3** |
| Managed relational DB | **RDS** (consider Aurora as upgrade path) |
| Reduce latency with caching | **CloudFront**, **ElastiCache** |

---

## 🔍 Review & Continuous Improvement

**Review (before building)**

- Use **CloudFormation** to standardize/repeat infra (and avoid “snowflake” setups)

**Stay updated**

- Track AWS updates (AWS News / blogs) to leverage new performance features

---

## 📈 Monitoring (How to know performance is “good”)

- **CloudWatch metrics/alarms/dashboards**
- For **Lambda**: watch latency/duration, errors, throttles, concurrency

---

## ⚖️ Trade-offs (Exam Favorite)

Performance decisions always trade off something:

### Caching Trade-off

- **CloudFront / ElastiCache** ⇒ faster reads, lower latency
- Risk: **stale/outdated content** until cache expires (TTL) or invalidation

### Database Trade-off

- **RDS vs Aurora** (common scenario question)
- Aurora often chosen for higher performance/availability patterns (conceptually)

### Data Transfer Trade-off

- **Network transfer**: immediate, but can consume bandwidth / take long
- **Snowball**: large data move, **fast transfer capacity**, but **shipping delay**

---

## 🧠 CLF-002 “Answer Pattern” (When you see a scenario)

### Performance Efficiency playbook

1. **Select** the right service for the workload
2. **Review** architecture via IaC
3. **Monitor** with CloudWatch
4. **Trade off** (cache freshness, cost, delivery time)

---

## 🗺️ Mini Flowchart (Copy into Notion)

**Performance troubleshooting loop**

```plain text
Slow / high latency?
   ↓
CloudWatch metrics + alarms
   ↓
Bottleneckfound?
   ├─ Compute → Auto Scaling / Lambda
   ├─Storage → EBStype / S3 pattern
   ├─ DB → RDS tuning / consider Aurora
   └─ Latencyto users → CloudFront (cache)
   ↓
Re-test + iterate (experiment more often)

```