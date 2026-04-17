---
notion-id: 2af5a6e2-1812-8042-851b-d17a834c8617
---
## 1. What is an EBS Snapshot?

An **EBS Snapshot** is a **point-in-time backup** of an EBS volume.

- Stored in **Amazon S3 (managed, not visible directly)**
- Can restore snapshots into **new EBS volumes**
- Allows **moving data across AZs or Regions**

Snapshots are **incremental**:

- Only changed data blocks are saved → faster & cheaper.

---

## 2. Why Use Snapshots?

| Purpose | Description |
| --- | --- |
| **Backup** | Restore EBS volume to previous state anytime |
| **AZ migration** | Create volume in another AZ from snapshot |
| **Region migration** | Copy snapshot across regions |
| **Data protection** | Keep historical backups |

---

## 3. How EBS Snapshot Works (Diagram)

### 📌 Moving a Volume From `us-east-1a` → `us-east-1b`

```plain text
[EC2 + EBS Volume in us-east-1a]
            │
            ▼
     Create Snapshot
            │
            ▼
[EBS Snapshot stored in us-east-1 Region]
            │
            ▼
 Restore Snapshot into New EBS Volume
            │
            ▼
[EC2 + New Volume in us-east-1b]


```

---

## 4. Snapshot Creation Notes

| Question | Answer |
| --- | --- |
| Do you need to stop the EC2 instance? | ❌ Not required |
| Is stopping recommended for a cleaner backup? | ✔ Yes |
| Are snapshots incremental? | ✔ Yes |
| Can you restore from a terminated EBS volume? | ✔ Yes |

---

## 5. Snapshot Features You MUST Know for CLF-C02

### ⭐ (1) **EBS Snapshot Archive**

Move snapshots into a **low-cost archive tier** (up to **75% cheaper**).

| Feature | Value |
| --- | --- |
| Cost | 75% cheaper |
| Restore time | **24–72 hours** |
| Use case | Long-term storage, rarely accessed backups |

**Important for exam:**

Archive = cheap, slow, long-term.

---

### ⭐ (2) **Recycle Bin for Snapshots**

Protects against *accidental deletion*.

| Feature | Description |
| --- | --- |
| What happens when snapshot is deleted? | Moved to Recycle Bin (not immediately lost) |
| Retention | 1 day → 1 year |
| Use case | Safety net for important snapshots |

---

## 6. Snapshot vs. Volume Comparison Table

| Feature | EBS Volume | EBS Snapshot |
| --- | --- | --- |
| Type | Block storage | Backup |
| AZ-bound? | ✔ Yes | ❌ No (Region-level) |
| Can copy across Regions? | ❌ No | ✔ Yes |
| Incremental? | ❌ No | ✔ Yes |
| Used for restore? | — | ✔ Create new EBS volume |

---

## 7. Exam Tips & Common Questions (High-Yield)

### ❓ *"How do you move an EBS volume to another AZ?"*

✔ Create a **snapshot**, then restore it in the new AZ.

---

### ❓ *"A company wants cheaper storage for old snapshots. Which feature?"*

✔ **Snapshot Archive**

---

### ❓ *"Snapshots accidentally deleted. How to recover?"*

✔ **Recycle Bin for Snapshots**

---

### ❓ *"Do snapshots require the EBS volume to be detached?"*

✔ No — but detaching or stopping instance provides a **cleaner snapshot**.

---

# 📌 Final Summary for CLF-C02

- EBS Snapshot = point-in-time backup stored in S3.
- Does *not* require detaching volume (optional).
- Copy snapshots across AZs/Regions.
- Snapshot Archive = 75% cheaper, 24–72h restore time.
- Recycle Bin = protects from accidental deletion (1 day–1 year retention).
- Snapshots are **incremental**.