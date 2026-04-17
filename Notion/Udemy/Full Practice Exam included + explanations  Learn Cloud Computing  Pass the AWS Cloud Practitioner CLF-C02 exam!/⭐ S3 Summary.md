---
notion-id: 2b45a6e2-1812-8077-885a-faf47f64077e
---
## Core Concepts: Buckets & Objects

- **Buckets** store objects and must have a **globally unique name**.
- Each bucket resides in a **specific AWS Region**.
- **Objects** are the actual files stored inside buckets.

---

## S3 Security

- **IAM policies** control access for users and roles.
- **Bucket policies** control access at the bucket and object level
(e.g., enabling public read access).
- **S3 encryption** protects data at rest using server-side or client-side encryption.

---

## Static Website Hosting

- S3 can host **static websites**.
- The bucket must allow **public read access**.
- Website content is served directly through an S3 website endpoint.

---

## S3 Versioning

- Stores **multiple versions** of the same object.
- Prevents accidental deletions.
- Enables rollback to previous versions.
- Required for S3 replication features.

---

## S3 Replication

Two replication modes:

- **Same-Region Replication (SRR)**
- **Cross-Region Replication (CRR)**

Requirements:

- Versioning must be **enabled** on both source and destination buckets.

---

## S3 Storage Classes

Key classes covered:

- **Standard** (frequent access)
- **Standard-Infrequent Access**
- **One Zone-Infrequent Access**
- **Intelligent Tiering**
- **Glacier Instant Retrieval**
- **Glacier Flexible Retrieval**
- **Glacier Deep Archive**

These support different performance, cost, and retrieval time needs.

---

## Snowball

- Physical devices for **large-scale data migration** to S3.
- Also supports **edge computing** using local EC2 and Lambda capabilities.
- Useful for limited connectivity environments or large data transfers.

---

## Storage Gateway

- Hybrid cloud storage solution.
- Bridges **on-premises environments** with AWS.
- Supports file, block, and tape interfaces.
- Commonly used for **backup, disaster recovery, and cloud-backed storage**.