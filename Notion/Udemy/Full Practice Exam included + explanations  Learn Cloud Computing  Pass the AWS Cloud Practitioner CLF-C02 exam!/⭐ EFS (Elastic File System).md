---
notion-id: 2b05a6e2-1812-8022-912e-d6d3982f4a75
---
## 1. What Is EFS?

**EFS (Elastic File System)** is a **fully managed network file system (NFS)** that can be mounted to **hundreds of EC2 Linux instances** at the same time.

> Shared, scalable, multi-AZ, network-based file storage.

EFS 特性：

- Shared across many EC2 instances
- Works across multiple AZs
- No capacity planning → pay per use
- Highly available & scalable
- More expensive than EBS (~3× gp2 price)

---

# 2. Key Differences: EFS vs EBS (必考)

| Feature | **EFS** | **EBS** |
| --- | --- | --- |
| Storage type | Network File System (NFS) | Block storage |
| Shared access | ✔ Yes (hundreds of EC2) | ❌ No (single instance per AZ) |
| Multi-AZ | ✔ Yes | ❌ No (AZ-bound) |
| OS support | Linux only | Linux & Windows |
| Scaling | Automatic (no size planning) | Must provision size |
| Pricing | Higher | Lower |
| Persistence | Persistent | Persistent |
| Use cases | Shared data, web servers, containers | Databases, single-instance storage |

---

# 3. EFS Architecture (Diagram)

```plain text
               EFS File System
                  (Multi-AZ)
          ┌─────────┬─────────┬─────────┐
          │         │         │         │
   ┌──────▼──────┐ ┌▼───────┐ ┌▼───────┐
   │ EC2 in AZ1  │ │ EC2 in │ │ EC2 in │
   │  us-east-1a │ │ 1b     │ │ 1c     │
   └─────────────┘ └────────┘ └────────┘
        All instances mount the same data


```

✔ All instances see the **same files**

✔ Perfect for shared content (websites, CMS, user uploads)

---

# 4. EBS vs EFS Example Explanation

### **EBS**

- Can only attach to **1 instance in 1 AZ**
- If you want data in another AZ → need Snapshot → restore → copy (NOT real-time sync)
- Good for: databases, OS drives, individual workloads

### **EFS**

- Multiple instances can attach simultaneously
- Shared storage (real-time synced)
- Works across AZs
- Good for:
    - Web server shared content
    - Container clusters (ECS/EKS)
    - Home directories
    - Shared configuration files

---

# 5. EFS Storage Classes (必考)

### ⭐ (1) EFS Standard

- Default storage class
- For frequently accessed files

### ⭐ (2) EFS Infrequent Access (EFS-IA)

- Up to **92% cheaper**
- Used for files not accessed frequently
- Automatically transitions based on **lifecycle policy**

---

# 6. EFS Lifecycle Policies (Automatic Tiering)

EFS 可以根據檔案最後的存取時間，自動把檔案搬到低成本 EFS-IA。

### Example Flow

```plain text
EFS Standard (files)
│ file1 accessed yesterday
│ file2 accessed today
│ file3 accessed 20 days ago
│ file4 accessed 60 days ago ← Criteria matched
│
└── Lifecycle policy: Move files not accessed for 60 days → EFS-IA


```

So file4 is moved to EFS-IA automatically.

When file4 is accessed again:

→ Automatically moved back to **EFS Standard**

✔ Transparent to the application

✔ No code changes required

---

# 7. EFS-IA Diagram

```plain text
          EFS File System
       ┌──────────┬───────────┐
       │          │           │
 EFS Standard   EFS-IA (92% cheaper)
 │ file1        │ file4 (cold)
 │ file2        │
 │ file3        │
└───────────────┴────────────────
Automatic lifecycle transitions


```

---

# 8. Best Use Cases for EFS

| Use Case | Reason |
| --- | --- |
| Web servers sharing media | Shared writable file system |
| Multi-AZ workloads | EFS = multi-AZ |
| Application configuration directories | Shared among fleet |
| Container storage (ECS/EKS) | Multi-host shared data |
| Big data & analytics | Scalable + shared |

Avoid using EFS for:

- Databases with high IOPS requirements
→ Use EBS or Instance Store instead

---

# 9. CLF-C02 Exam Key Points

### ⭐ EFS = Shared network file system for Linux EC2

### ⭐ Supports **multi-AZ** access

### ⭐ Can mount to **hundreds of EC2 instances**

### ⭐ Storage classes: **EFS Standard** & **EFS-IA**

### ⭐ EFS-IA = up to **92% cheaper**

### ⭐ Lifecycle policies automatically move files between classes

### ⭐ Pay only for what you store (no capacity provisioning)

### ⭐ More expensive than EBS (about 3× gp2)

---

# 📌 One-Sentence Summary

> EFS is a fully managed, scalable, shared multi-AZ file system for Linux EC2 instances, supporting hundreds of mounts and automatic lifecycle-based cost optimization (EFS-IA).