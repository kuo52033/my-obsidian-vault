---
notion-id: 2b45a6e2-1812-8025-b84e-ef29a33c1a98
---
## What Is AWS Storage Gateway?

AWS Storage Gateway is a **hybrid storage service** that connects your **on-premises environments** with **AWS cloud storage**.

It allows existing local systems to use AWS storage as if it were part of the local infrastructure.

This is essential when organizations want to:

- Gradually migrate to the cloud
- Keep certain workloads on-premises due to compliance
- Retain legacy applications that rely on traditional file/block/tape interfaces
- Use AWS as a backup or disaster recovery target

---

## Why Storage Gateway Exists

Amazon S3 is an **object storage** service, which cannot be mounted directly using traditional file protocols like NFS or SMB.

Storage Gateway solves this by acting as a **bridge**:

- On-premises apps see familiar **file**, **block**, or **tape** interfaces
- Behind the scenes, data is stored in **S3**, **EBS**, or **Glacier**

---

## Storage Types on AWS (Context)

| Category | AWS Service |
| --- | --- |
| **Block Storage** | EBS, EC2 Instance Store |
| **File Storage** | EFS |
| **Object Storage** | S3, Glacier |
| **Hybrid Storage** | Storage Gateway |

Storage Gateway expands on-premises storage into AWS.

---

## Storage Gateway Use Cases

- **Backup and Restore** (replace physical tape libraries)
- **Disaster Recovery** (cloud-based replicas of on-premises volumes)
- **Cloud-backed file shares** (store local files but archive to S3)
- **Tiered storage** (frequently accessed locally, older data in S3/Glacier)

---

## Storage Gateway Types (High-Level)

Although deep details are not required for CLF-C02, you should know the three types exist:

### 1. **File Gateway**

- Provides **NFS/SMB** file share interfaces
- Files stored as **objects in S3**

### 2. **Volume Gateway**

- Block storage volumes that **replicate to AWS**
- Used for backup & disaster recovery
- Backed by **EBS snapshots**

### 3. **Tape Gateway**

- Virtual tape library (VTL) for backup software
- Archives tapes into **S3 Glacier**

---

## Exam Perspective (CLF-C02)

Key things to remember:

- Storage Gateway = **Hybrid storage service to bridge on-premises and AWS**
- Supports **file, block, and tape** interfaces
- Stores data in **S3, EBS, and Glacier behind the scenes**
- Used for **backup, DR, and cloud extension of on-premises storage**