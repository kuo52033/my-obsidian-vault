---
notion-id: 2b45a6e2-1812-80e3-b560-c9d2f4405d14
---
Amazon S3 offers multiple storage classes designed for different access patterns, cost requirements, and retrieval needs.

All S3 storage classes provide **11 nines (99.999999999%) durability**, but differ in **availability**, **cost**, and **retrieval times**.

---

# 1. Key Concepts: Durability vs Availability

### **Durability**

- Measures the likelihood of **data loss**
- S3 provides **11 nines durability** for all storage classes
→ If you store 10 million objects, you may lose 1 object every 10,000 years.

### **Availability**

- Measures how often the service is accessible
- Varies by storage class
- Example:
    - S3 Standard: **99.99%** availability
    - Lower-cost classes → lower availability

---

# 2. S3 Storage Classes

## **1. S3 Standard – General Purpose**

- High availability: **99.99%**
- Low latency, high throughput
- Resilient to **two concurrent AZ failures**
- **Use cases:**
    - Frequently accessed data
    - Big data analytics
    - Mobile & gaming apps
    - Content distribution

---

## **2. S3 Standard–Infrequent Access (S3 Standard-IA)**

- Lower cost than Standard
- 99.9% availability
- Quick retrieval when needed
- Retrieval **fee applies**
- **Use cases:**
    - Disaster recovery
    - Backups
    - Infrequently accessed but important data

---

## **3. S3 One Zone–Infrequent Access (S3 One Zone-IA)**

- Stored in **a single Availability Zone**
- 99.5% availability (lowest among non-archive classes)
- Lost if the AZ is destroyed
- **Use cases:**
    - Secondary backups
    - Re-creatable data
    - On-premises backup copies

---

# 3. Glacier Storage Classes (Archive Tiers)

Designed for long-term archival with lower cost and slower retrieval.

## **4. S3 Glacier Instant Retrieval**

- Millisecond retrieval
- Minimum storage duration: **90 days**
- **Use cases:**
    - Archive data accessed once per quarter
    - Medical images, compliance archives

---

## **5. S3 Glacier Flexible Retrieval**

(Previously called "Glacier")

- Retrieval options:
    - **Expedited:** 1–5 minutes
    - **Standard:** 3–5 hours
    - **Bulk:** 5–12 hours
- Minimum storage: **90 days**
- **Use cases:**
    - Backup or archive data occasionally needed
    - Faster restore options than Deep Archive

---

## **6. S3 Glacier Deep Archive**

- **Lowest-cost** storage option in S3
- Retrieval:
    - **Standard:** up to 12 hours
    - **Bulk:** up to 48 hours
- Minimum storage: **180 days**
- **Use cases:**
    - Long-term archival (7–10+ years)
    - Compliance and cold storage

---

# 4. S3 Intelligent-Tiering

Automatically moves objects between access tiers based on usage patterns.

### Features:

- Small monthly **monitoring and automation fee**
- **No retrieval charges**
- Designed for **unknown or changing** access patterns

### Tiers:

- **Frequent Access** (default)
- **Infrequent Access** (objects not accessed for 30 days)
- **Archive Instant Access** (90 days)
- **Archive Access** (optional: 90–700+ days)
- **Deep Archive Access** (optional: 180–700+ days)

### Benefits:

- Automatic cost optimization
- No performance impact
- No manual lifecycle setup required

---

# ⭐ Summary Table

| Storage Class | Availability | Retrieval | Cost | Main Use Case |
| --- | --- | --- | --- | --- |
| **Standard** | 99.99% | Milliseconds | Higher | Frequent access |
| **Standard-IA** | 99.9% | Milliseconds | Lower + retrieval fee | Backups, DR |
| **One Zone-IA** | 99.5% | Milliseconds | Lowest of non-archive | Re-creatable data |
| **Glacier Instant Retrieval** | 99.9% | Milliseconds | Low | Quarterly access |
| **Glacier Flexible Retrieval** | 99.99% | Minutes–Hours | Very low | Archive with occasional need |
| **Glacier Deep Archive** | 99.99% | Hours–Days | Lowest | Long-term cold archive |
| **Intelligent-Tiering** | 99.9%–99.99% | Varies | Dynamic | Unknown / variable access patterns |

---

# 📌 One-Sentence Summary

> S3 offers multiple storage classes across frequent-access, infrequent-access, and archival tiers, all with 11 nines durability but different costs, availability, and retrieval times to match your data access patterns.