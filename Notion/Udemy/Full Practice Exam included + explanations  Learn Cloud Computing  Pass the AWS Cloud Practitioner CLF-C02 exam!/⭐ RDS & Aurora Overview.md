---
notion-id: 2b55a6e2-1812-80dd-af9a-fa5832da569a
---
---

## 📌 What Is Amazon RDS?

**Amazon RDS (Relational Database Service)** is a fully managed service for running **SQL relational databases** on AWS.

### ✔ Supported Database Engines

| Engine | Notes |
| --- | --- |
| MySQL | Open-source SQL |
| PostgreSQL | Open-source SQL |
| MariaDB | Open-source |
| Oracle | Commercial |
| SQL Server | Commercial |
| IBM DB2 | Enterprise |
| **Aurora** | AWS-proprietary (MySQL & PostgreSQL compatible) |

---

## ✅ Why Use RDS Instead of Installing Databases on EC2?

AWS handles all the undifferentiated heavy lifting:

### **Managed by AWS**

- Automatic provisioning
- Automated OS + DB patching
- Continuous backups + Point-in-Time Restore
- Monitoring dashboards (CloudWatch)
- Multi-AZ for high availability
- Read Replicas for read scaling
- Maintenance windows
- Storage backed by EBS
- Vertical & horizontal scaling

### **Important Restriction**

- ❌ **No SSH access** to the DB host (AWS manages it fully)

---

## 🏗 RDS in a Typical Architecture (Diagram)

```plain text
       Client
         │
         ▼
   Application LB
         │
         ▼
   EC2 Auto Scaling Group
         │
         ▼
   ┌──────────────────┐
   │   RDS Database   │
   │ (Relational DB)  │
   └──────────────────┘
```

Backend EC2 instances send SQL reads/writes to the RDS database.

---

# ⭐ Amazon Aurora Overview

**Aurora** is an AWS-built relational database compatible with **MySQL** and **PostgreSQL**.

It is not open-source, but fully managed and **cloud-optimized** for performance and availability.

---

## 🚀 Aurora Performance Benefits

| Feature | Aurora | RDS |
| --- | --- | --- |
| Performance | Up to **5× MySQL** / **3× PostgreSQL** | Baseline open-source performance |
| Storage Scaling | Auto-scales 10 GB → **256 TB** | Manual EBS scaling |
| Availability | 6 copies across 3 AZs | Multi-AZ (2 copies) |
| Cost | ~20% more per instance | Cheaper but lower performance |

---

## Aurora Architecture (Visual)

```plain text
               Aurora Cluster
         ┌────────────────────────┐
         │       Writer Node       │
         │   (read/write endpoint) │
         └────────────────────────┘
                 ▲
                 │
      Same shared distributed storage
                 │
   ┌────────────────────────┐
   │      Reader Node(s)     │
   │   (read-only endpoint)  │
   └────────────────────────┘


```

### Key Concepts

- **Aurora replicates storage across 3 AZs**
- **Compute and storage are decoupled**
- Readers and writer share the same storage volume

---

# ⭐ Aurora Serverless

A fully managed, auto-scaling version of Aurora.

### ✔ Key Benefits

- No servers to manage
- Auto-scales DB capacity based on usage
- Pay per second
- Ideal for **infrequent, unpredictable, or sporadic workloads**
- Supports **MySQL** and **PostgreSQL** engines

---

## Aurora Serverless Architecture (Diagram)

```plain text
                   Client
                     │
                     ▼
            Aurora Serverless Proxy Fleet
                     │
                     ▼
   ┌────────────────────────────────────┐
   │  Auto-provisioned Aurora Instances │
   │ (Scale up/down, warm pools, etc.) │
   └────────────────────────────────────┘
                 Shared Storage


```

---

# ⭐ RDS vs Aurora (Exam-Ready Comparison)

| Feature | RDS | Aurora |
| --- | --- | --- |
| Engines | MySQL, PostgreSQL, MariaDB, Oracle, SQL Server, IBM DB2 | Aurora MySQL, Aurora PostgreSQL |
| Performance | Standard | **5× MySQL / 3× PostgreSQL** |
| Storage | EBS-based | Auto-scaling distributed storage |
| Replication | Read replicas | Up to 15 read replicas |
| Availability | Multi-AZ | 6 copies across 3 AZs |
| Pricing | Cheaper | ~20% higher per instance, more efficient |
| Serverless Option | ❌ No | **✔ Aurora Serverless** |
| Best For | Traditional SQL workload | High-performance cloud-native apps |

---

# 🎯 Exam Tips

- RDS = **fully managed SQL database service**
- Aurora = **AWS cloud-native SQL database, higher performance**
- Aurora Serverless = **automatic scaling + pay per second**
- You cannot SSH into RDS or Aurora
- RDS storage is based on **EBS**
- Aurora storage auto-scales to **256 TB**
- Aurora is more expensive but often more cost-effective due to performance