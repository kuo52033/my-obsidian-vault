---
notion-id: 2af5a6e2-1812-804b-9975-fc168c5360dc
---
## 1. What is EBS?

**EBS (Elastic Block Store)** is a **network-based block storage service** used with EC2 instances.

- Acts like a **network-attached USB drive**.
- Supports **persistent storage** — data remains even if the EC2 instance is terminated (unless configured otherwise).
- Can be **detached** from one EC2 instance and **re-attached** to another.
- EBS volumes are **AZ-bound** (Availability Zone specific).

### Key Exam Points

- EBS = **block storage**, not file storage.
- EBS persists data **independently** of EC2 lifecycle.
- You must choose **size** and **IOPS** (performance) ahead of time.

---

## 2. EBS Volume Characteristics

### 🔹 Network Drive

EBS is not a physical disk inside the EC2 instance.

It communicates over the network → can have **slightly higher latency** than local instance storage.

### 🔹 Can Attach/Detach Easily

- You can detach a volume and re-attach it to another EC2 instance **in the same AZ**.
- Fast & convenient for backups, migrations, failover.

### 🔹 AZ-locking

Every EBS volume belongs to **one specific Availability Zone**.

Example:

A volume created in `us-east-1a` **cannot** be attached to an instance in `us-east-1b`.

To move EBS across AZ or Region:

- Create **EBS Snapshot**
- Restore the snapshot into another AZ/Region

### 🔹 Capacity & Performance Provisioning

When creating a volume, you predefine:

- Volume size (GB)
- IOPS (I/O operations per second)
- Volume type (gp3, io2, st1, etc.)

Billing is **provisioned capacity**, not actual usage.

---

## 3. EBS Volume Attachment Scenarios

### ✔ One EBS Volume → One EC2 Instance (at CCP level)

You cannot attach **one EBS volume to multiple EC2 instances at once**

(except with *EBS Multi-Attach*, but **that is not on CLF-C02**).

### ✔ One EC2 Instance → Multiple EBS Volumes

You can attach multiple EBS volumes to a single EC2 instance (like multiple USB drives).

### ✔ Unattached Volumes

EBS volumes can exist without being attached to any instance — useful for:

- Creating volumes before launching EC2
- Storing data independently

---

## 4. Delete on Termination Attribute

When launching an EC2 instance, EBS volumes have a setting:

| Volume | Delete on Termination (Default) | Result |
| --- | --- | --- |
| **Root (boot) volume** | Enabled | Deleted when EC2 is terminated |
| **Additional volumes** | Disabled | Volume persists after termination |

### Why This Matters for the Exam

- If you want to **keep the root volume** after instance termination → disable "delete on termination".
- Additional volumes **must be manually deleted** unless this setting is enabled.

This is a common exam scenario.

Example question:

> You terminate an EC2 instance but want the root disk data to remain. What must you do?
> Correct answer: **Disable delete-on-termination for the root volume.**

---

## 5. EBS in Diagrams (Mental Model)

- EBS is tied to a **single AZ**
- EC2 instances can have **multiple volumes**
- EBS volumes can be **moved to other AZs** only via **Snapshots**

---

## 6. Additional Exam Tips (CLF-C02)

### EBS Volume Types (high-level)

You only need general awareness:

- **gp3** – General Purpose SSD (default, flexible IOPS)
- **io2/io2 Block Express** – High-performance SSD for databases
- **st1** – Throughput-optimized HDD (big data)
- **sc1** – Cold HDD (infrequent access)

### EBS Snapshots

- Stored in **S3 (managed by AWS, not directly visible)**.
- Allow copying EBS volumes across **AZs or Regions**.
- Incremental backups (only changes are stored).

### EBS vs Instance Store (high-level distinction)

| EBS | Instance Store |
| --- | --- |
| Persistent | Non-persistent (data lost on stop/terminate) |
| AZ-bound network storage | Physical disk on the host |
| Slower (network) | Very fast |
| Can snapshot | Cannot snapshot |

---

# 📌 Summary for CLF-C02

- EBS = persistent block storage for EC2.
- Network-attached, AZ-specific.
- Detachable and reattachable (same AZ).
- Delete-on-termination determines whether the volume is preserved.
- Use snapshots to move EBS volumes across AZ/Region.
- Root volume is deleted by default; extra volumes are not.