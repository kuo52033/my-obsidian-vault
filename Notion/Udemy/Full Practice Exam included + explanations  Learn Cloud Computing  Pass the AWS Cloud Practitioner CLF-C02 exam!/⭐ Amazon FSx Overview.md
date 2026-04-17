---
notion-id: 2b05a6e2-1812-805b-b56e-f19624ac07d5
---
## 1. What Is Amazon FSx?

Amazon FSx is a **fully managed service** that provides **high-performance third-party file systems** on AWS.

You use FSx when:

- EFS is not suitable (Linux-only, NFS)
- S3 is not a file system
- You need Windows-native features or HPC-optimized storage

Current major FSx offerings:

1. **FSx for Windows File Server**
2. **FSx for Lustre**
3. **FSx for NetApp ONTAP** (not heavily tested in CLF-C02)

For the exam, focus on:

- FSx for Windows
- FSx for Lustre

---

# 2. FSx for Windows File Server

A fully managed, highly available **Windows-native file system**.

### Key Features

- Built on **Windows File Server**
- Uses **SMB protocol** (Server Message Block)
- Supports **Windows NTFS**
- Integrates with **Microsoft Active Directory**
- Multi-AZ deployments for high availability
- Accessible from:
    - EC2 Windows instances
    - On-premises systems via SMB

### Architecture (Diagram)

```plain text
On-Premises Clients (Windows)
          │  SMB
          ▼
 ┌──────────────────────────┐
 │ FSx for Windows FileSrv │
 │ Multi-AZ Deployment     │
 └──────────────────────────┘
          ▲
          │ SMB
          ▼
   Windows EC2 Instances
```

### Typical Use Cases

- Windows enterprise file shares
- Home directories
- Department shared drives
- Applications requiring SMB + NTFS

---

# 3. FSx for Lustre

A fully managed, **high-performance** file system used for **HPC workloads**.

### Key Characteristics

- Designed for **high-performance computing (HPC)**
- Extremely high throughput
→ hundreds of GB/s
- Millions of IOPS
- Sub-millisecond latency
- Integrates with **S3** as a backend (import/export data)
- Name meaning: **Lustre = Linux + Cluster**

### Architecture (Diagram)

```plain text
AWS Compute (EC2, HPC clusters)
            │
            ▼
  ┌────────────────────────┐
  │   FSx for Lustre       │
  │ High-performance FS    │
  └────────────────────────┘
            │
            ▼
        Amazon S3 (optional backend)


```

### Typical Use Cases

- Machine learning training
- Data analytics
- Video rendering
- Scientific computing
- Financial modeling

---

# 4. FSx Comparison Table (Exam-Focused)

| Feature | **FSx for Windows File Server** | **FSx for Lustre** |
| --- | --- | --- |
| Protocol | SMB | POSIX |
| OS | Windows only | Linux/HPC |
| Purpose | Enterprise Windows file shares | High-performance computing (HPC) |
| Performance | High | **Extremely high (HPC-grade)** |
| AD Integration | Yes | No |
| Storage Backend Option | NTFS | S3 integration |
| Typical Use | Home dirs, Windows apps | ML, analytics, video processing |

---

# 5. CLF-C02 Exam Key Points

### ⭐ FSx for Windows File Server

- Windows-native
- Supports SMB and NTFS
- Integrates with Active Directory
- Accessible from on-prem or AWS

### ⭐ FSx for Lustre

- HPC-optimized
- Very high throughput & IOPS
- Used for ML, analytics, rendering, etc.
- Integrated with S3

### ⭐ FSx exists because EFS and S3 cannot handle:

- Windows workloads (needs SMB/NTFS)
- HPC workloads (needs extreme performance)

---

# 📌 One-Sentence Summary

> Amazon FSx provides managed third-party file systems—Windows File Server for Windows workloads, and Lustre for high-performance computing.

# ⭐ FSx 相較其他 AWS Storage 的優勢整理

| 服務 | 優勢 | 適用情境 |
| --- | --- | --- |
| **EBS** | 單機高速、可快照 | 單台 EC2 的系統碟/資料碟 |
| **Instance Store** | 最高 I/O效能 | 暫存、快取、短期運算 |
| **EFS** | Linux 多機共享、跨 AZ | Web 伺服器共用檔案、容器儲存 |
| **S3** | 物件儲存、高耐久、便宜 | 靜態檔案、備份、資料湖 |
| **FSx for Windows** | SMB + NTFS + AD | Windows 應用、企業檔案共享 |
| **FSx for Lustre** | HPC 最高效能檔案系統 | ML、分析、動畫渲染、HPC |
| **FSx for ONTAP** | NetApp 儲存功能移植到 AWS | 混合雲、企業級儲存需求 |