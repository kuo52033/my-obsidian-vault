---
notion-id: 2b35a6e2-1812-80fd-9c71-ddbb8a961ed8
---
Amazon S3 offers two replication options that automatically copy objects from one bucket to another:

- **CRR (Cross-Region Replication)**
- **SRR (Same-Region Replication)**

Replication is **asynchronous** and requires **versioning** to be enabled.

---

# 1. How S3 Replication Works

Replication copies objects from a **source bucket** to a **destination bucket**.

### Requirements:

- **Versioning must be enabled** on both source and destination buckets
- Proper **IAM permissions** must be granted to S3 for reading/writing objects
- For CRR: buckets must be in **different regions**
- For SRR: buckets must be in **the same region**
- Buckets can be in **different AWS accounts**

Replication happens in the background, not in real time.

---

# 2. CRR — Cross-Region Replication

Replicates objects to a bucket in **another AWS Region**.

### Use Cases:

- **Compliance**: meet regulatory or business requirements by storing data in a separate region
- **Latency reduction**: keep data closer to users in another region
- **Cross-account replication**: store replicated data in a backup or security account
- **Disaster recovery**: maintain a remote copy of critical data

---

# 3. SRR — Same-Region Replication

Replicates objects to a bucket **within the same region**.

### Use Cases:

- **Log aggregation**: centralize logs from multiple S3 buckets
- **Production → test duplication**: maintain a live replica of production data for testing
- **Data segregation**: keep copies of data in separate accounts for security or access isolation

---

# 4. Important Notes

- Replication is **not retroactive** — only new or updated objects are replicated unless explicitly configured otherwise
- Replication supports **encrypted objects**, but requires proper permissions
- Versioning must remain **enabled** for replication to continue functioning

---

# ⭐ Summary Table

| Replication Type | Regions | Common Use Cases |
| --- | --- | --- |
| **CRR** | Source & destination in different regions | Compliance, DR, lower latency, cross-account backup |
| **SRR** | Both buckets in the same region | Log aggregation, prod-to-test sync, access separation |

---

# 📌 One-Sentence Summary

> S3 Replication (CRR and SRR) asynchronously copies versioned objects between buckets—across regions or within the same region—to support compliance, backups, testing, and data aggregation.