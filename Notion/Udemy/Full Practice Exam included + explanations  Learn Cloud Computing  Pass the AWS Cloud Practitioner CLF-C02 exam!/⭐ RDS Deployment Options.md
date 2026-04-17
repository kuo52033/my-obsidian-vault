---
notion-id: 2b55a6e2-1812-80ef-9ba3-d62916fdfafd
---
AWS RDS supports multiple deployment architectures depending on your requirements for **scalability**, **availability**, and **global access**.

---

## **1️⃣ Read Replicas — Scale Reads**

**Purpose:** Improve read throughput by creating additional read-only copies.

### ✔ Key Points

- Up to **15 Read Replicas** per DB.
- Applications read from replicas, **writes always go to the primary**.
- Replication is **asynchronous** → replicas **may have slight lag**.
- Used for:
    - Read-heavy applications
    - Reporting / analytics
    - Offloading queries from primary DB

### 📘 Diagram

```plain text
        Writes
   App ─────────► Primary RDS
                  │
      Reads       │  async replication
   App ─────────► Read Replica 1
   App ─────────► Read Replica 2


```

---

## **2️⃣ Multi-AZ — High Availability (Failover)**

**Purpose:** Automatic failover during AZ outages.

### ✔ Key Points

- Creates a **standby** DB instance in another AZ.
- Replication is **synchronous** (data fully consistent).
- Applications still interact with **one endpoint**.
- Standby cannot be read or written until failover happens.
- Provides:
    - HA & durability
    - Automatic failover during AZ failure
    - No performance improvement for reads

### 📘 Diagram

```plain text
 App → Primary RDS (AZ-1)
          │  synchronous replication
          ▼
     Standby RDS (AZ-2)
       (not accessible)


```

---

## **3️⃣ Multi-Region Read Replicas — Global Performance + DR**

**Purpose:** Distribute read load globally & enable cross-region disaster recovery.

### ✔ Key Points

- Read replicas located in **different regions**.
- Local applications read from nearby region = **low latency**.
- All **writes must go to the primary region**.
- Provides:
    - **Global read performance**
    - **Cross-region disaster recovery**
- **Additional cost** due to cross-region data transfer.

### 📘 Diagram

```plain text
            Writes
      App (US) ──────────►  Primary RDS (EU)
                                │
        async cross-region      │
                                ▼
                      Read Replica (US)
                      Read Replica (APAC)


```

---

## ⭐ Summary Table

| Deployment Type | Purpose | Read Scaling | High Availability | Global Access | Notes |
| --- | --- | --- | --- | --- | --- |
| **Read Replicas** | Scale reads | ✔ Yes | ✖ No | ✔ With multi-region | Async replication |
| **Multi-AZ** | HA + DR (AZ-level) | ✖ No | ✔ Yes | ✖ Same region only | Sync replication |
| **Multi-Region Replicas** | Global low-latency + DR | ✔ Yes | ✖ No | ✔ Global | Cross-region cost |

RDS Multi-AZ 使用同步複寫，是因為 HA 不可允許資料遺失（zero data loss）。

Read Replicas 使用非同步複寫，是因為它的目的不是 HA，而是 read scalability。
