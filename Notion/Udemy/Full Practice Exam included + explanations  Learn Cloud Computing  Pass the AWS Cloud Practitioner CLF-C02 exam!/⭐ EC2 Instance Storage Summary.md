---
notion-id: 2b15a6e2-1812-80f0-afed-ee284c964241
---
## 1. EBS (Elastic Block Store)

- Network-attached block storage for EC2.
- Can attach **to one EC2 instance at a time**.
- **AZ-scoped** — an EBS volume belongs to a single Availability Zone.
- Supports **snapshots**, which are used for:
    - Backups
    - Restoring volumes
    - Copying data across Availability Zones or Regions
- Persistent storage: survives instance stop/terminate (unless delete-on-termination is enabled).

---

## 2. AMIs (Amazon Machine Images)

- Preconfigured **EC2 instance images** containing OS, applications, and custom settings.
- Used to launch new EC2 instances with a consistent configuration.
- Can be created manually or automated using **EC2 Image Builder**.

### EC2 Image Builder

- Automates AMI creation, testing, and distribution.
- Can run on a schedule.
- Launches a **builder instance** and a **test instance** automatically.

---

## 3. EC2 Instance Store

- **Local hardware disk** physically attached to the EC2 host.
- Provides **very high I/O performance**.
- Data is **ephemeral**:
    - Lost when the instance stops or terminates
    - Lost if underlying hardware fails
- Ideal for temporary data such as cache, buffers, and scratch space.

---

## 4. EFS (Elastic File System)

- Fully managed **NFS file system**.
- Can be mounted to **hundreds of Linux EC2 instances** simultaneously.
- **Regional scope** (not tied to a single AZ).
- Scales automatically with storage usage.

### EFS-IA (Infrequent Access)

- Lower-cost storage class for rarely accessed files.
- Files move automatically based on lifecycle policies.

---

## 5. FSx (Amazon FSx)

Provides fully managed third-party file systems.

### FSx for Windows File Server

- Windows-native shared file system.
- Supports SMB and NTFS.
- Integrated with Active Directory.

### FSx for Lustre

- High-performance file system for **HPC workloads**.
- Very high throughput and IOPS.
- Suitable for ML, analytics, and large-scale data processing.

---

# 📌 Overall Summary

| Storage Type | Description | Best Use Case |
| --- | --- | --- |
| **EBS** | Network block storage, AZ-bound, persistent | Databases, durable per-instance storage |
| **AMI** | Prebuilt EC2 template | Fast deployments, standardized environments |
| **Instance Store** | Local ephemeral disk with highest I/O | Cache, temporary data, HPC scratch space |
| **EFS** | Shared NFS for Linux, multi-AZ | Web servers, shared content, containers |
| **FSx for Windows** | Windows SMB/NTFS file system | Windows workloads, enterprise file sharing |
| **FSx for Lustre** | HPC file system with extreme performance | ML training, analytics, rendering |