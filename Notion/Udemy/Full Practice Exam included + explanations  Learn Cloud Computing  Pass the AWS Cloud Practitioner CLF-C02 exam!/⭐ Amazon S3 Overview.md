---
notion-id: 2b35a6e2-1812-80fe-87c1-f29678e7abbc
---
Amazon S3 (Simple Storage Service) is one of the core building blocks of AWS.

It provides **infinitely scalable object storage** with high durability and broad integration across AWS services.

---

# 1. Key Use Cases for S3

S3 is used for almost any type of storage scenario:

- Backup and restore
- Disaster recovery (copy data to another Region)
- Archival storage (via Glacier tiers)
- Hybrid storage with on-premises environments
- Hosting media files (images, videos)
- Hosting static websites
- Software distribution
- Data lake storage for big data and analytics
- Storing application assets and log files

**Real-world examples:**

- NASDAQ stores 7 years of data on S3 Glacier.
- Cisco uses S3 as a data lake for analytics.

---

# 2. S3 Buckets

### What Are Buckets?

- Containers that store S3 objects.
- Represent “top-level directories” (conceptually).
- Every object is stored inside a bucket.

### Global Uniqueness Requirement

Bucket names must be **globally unique** across:

- All AWS accounts
- All AWS regions

However, buckets themselves are created **in a specific AWS Region**.

> S3 looks global, but buckets are regional resources.

---

# 3. Bucket Naming Rules

Bucket names:

- Must be **3–63 characters**
- Lowercase letters, numbers, and hyphens only
- Cannot contain uppercase or underscores
- Cannot be formatted like an IP address
- Must start with a lowercase letter or number

These rules support S3’s DNS-based addressing.

---

# 4. S3 Objects

### What Is an Object?

An individual file stored in S3.

An object includes:

- The file **content (body)**
- **Metadata** (key-value pairs)
- **Tags** (up to 10 key-value pairs)
- **Version ID** (if versioning is enabled)

### Object Size Limits

- Maximum object size: **5 TB**
- For any object **larger than 5 GB**, you **must** use **Multi-Part Upload**
    - Large files are uploaded in chunks (parts)
    - Improves reliability and performance

---

# 5. Object Keys (File Paths)

### What Is a Key?

A **key** is the full path to the object within the bucket.

Examples:

```plain text
my-file.txt
my-folder/another-folder/image.png


```

### Prefix + Object Name

Keys consist of:

- **Prefix** (folder-like path)
- **Object name** (final component)

Example:

```plain text
Key: myfolder1/another/myfile.txt
Prefix: myfolder1/another/
Object name: myfile.txt


```

### Important Clarification

S3 **does not actually have directories**.

Folders are a UI abstraction — S3 simply stores long key names containing slashes (`/`).

---

# ⭐ Summary Table

| Concept | Description |
| --- | --- |
| **Bucket** | Top-level container for objects; globally unique name; regional resource |
| **Object** | File + metadata + tags; up to 5 TB |
| **Key** | Full path to the object (prefix + name) |
| **Multi-Part Upload** | Required for files > 5 GB |
| **Versioning** | Allows multiple versions of the same key |

---

# 📌 One-Sentence Summary

> Amazon S3 is a highly scalable, durable object storage service that organizes data into buckets, stores files as objects with unique keys, and supports massive datasets and a wide range of cloud storage use cases.