---
notion-id: 2b05a6e2-1812-800e-9364-ef59d34de678
---
## 1. What Is EC2 Instance Store?

**EC2 Instance Store** is a **physical, local disk** *directly attached to the underlying hardware host* running your EC2 instance.

它不像 EBS，是：

> 真正的硬碟（NVMe / SSD / HDD）直接插在主機上 → 最快的 I/O 性能。

Instance Store 提供：

- Ultra-high IOPS
- Extremely low latency
- High throughput

但也有重大限制 → **資料不持久（ephemeral storage）**。

---

# 2. EC2 Instance Store vs EBS (必考表格)

| Feature | **Instance Store** | **EBS Volume** |
| --- | --- | --- |
| Type | **Local physical disk** | Network-attached disk |
| Persistence | ❌ Lost on stop/terminate | ✔ Persistent |
| Performance | ⭐ Extremely high (up to millions IOPS) | High but much lower |
| Latency | Very low | Higher (network-based) |
| Can detach? | ❌ No | ✔ Yes |
| Use case | Cache, buffer, temp data | Databases, production data |

---

# 3. Instance Store Behavior

### ✔ When does data get deleted?

| Action | Instance Store Data |
| --- | --- |
| **Stop EC2 instance** | ❌ Lost |
| **Terminate EC2 instance** | ❌ Lost |
| **Underlying hardware fails** | ❌ Lost |

That's why it's called **ephemeral storage**.

---

# 4. Good Use Cases (Exam Favorites)

Use Instance Store when data is:

- Temporary
- Regenerable
- Cached
- Buffered
- Part of batch/streaming processing
- Used as scratch space (e.g., EMR, Spark, temp DB writes)

Not suitable for:

❌ Databases

❌ Long-term data

❌ Anything requiring durability

For persistent data → use **EBS**.

---

# 5. Why Is Instance Store So Fast?

Because the disk is **physically attached** to the server hosting your EC2 instance:

```plain text
[EC2 Instance]
      │
  Direct PCIe/NVMe connection
      │
[Local Instance Store Disk]


```

No network.

No latency from EBS network calls.

Hence, **ultra-high I/O performance**.

---

# 6. Example Performance Comparison

| Storage Type | Performance |
| --- | --- |
| **Instance Store (I3 family)** | Up to **3.3 million** read IOPS |
| **EBS (gp3, io2)** | Up to **32,000 – 160,000** IOPS |

⭐ **Instance Store is an order of magnitude (10×–100×) faster**

→ this is an important exam clue.

---

# 7. Instance Store Architecture Diagram

```plain text
Physical Host
┌───────────────────────────┐
│   Local NVMe / SSD Disks  │ ← Instance Store
└─────────────┬─────────────┘
              │ (Direct attach)
              ▼
       EC2 Virtual Machine


```

Data is stored **on the same physical server**, so it disappears when:

- Instance stops/terminates
- Host fails

---

# 8. CLF-C02 Exam Key Points

### ⭐ Instance Store = Ephemeral Storage

- Data is NOT persistent
- Lost on stop/terminate

### ⭐ Instance Store = Very High Performance

If question mentions:

- *“highest disk performance”*
- *“millions of IOPS”*
- *“temporary caching layer”*
→ Answer is **EC2 Instance Store**.

### ⭐ Not for durable storage

Use EBS for persistent data.

### ⭐ Some EC2 types come with Instance Store

Example families: **I3, I4, D2, M5d, C5d**

(Do not need to memorize for CLF-C02, just recognize pattern)

---

# 📌 One-Sentence Summary

> EC2 Instance Store is ultra-fast, temporary local storage directly attached to the physical host—great for cache and temporary data, but not durable like EBS.