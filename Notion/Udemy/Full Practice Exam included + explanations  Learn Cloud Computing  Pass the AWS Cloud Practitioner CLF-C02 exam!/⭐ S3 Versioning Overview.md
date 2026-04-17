---
notion-id: 2b35a6e2-1812-80be-bd65-d4a0f58e0ec0
---
Amazon S3 **Versioning** allows you to preserve, retrieve, and restore every version of every object stored in a bucket.

It is a powerful feature for data protection, rollback, and accidental deletion recovery.

---

# 1. What Is S3 Versioning?

Versioning is a **bucket-level setting**.

When enabled, S3 keeps **multiple versions** of an object under the same key.

### How it works:

- Upload an object to `myfile.txt` → Version **1**
- Upload a new file to the same key → Version **2**
- Upload again → Version **3**

S3 stores all versions unless explicitly deleted.

---

# 2. Benefits of Versioning

### ✔ Protects Against Accidental Deletes

Deleting an object **does not remove data**.

Instead, S3 places a **delete marker**, preserving previous versions.

### ✔ Easy Rollback

You can restore any previous version of a file:

- Useful when updating a static website
- Useful for configuration files, logs, important data

### ✔ Data Protection and Backup Strategy

Versioning is a recommended best practice for critical data.

---

# 3. Behavior Notes (Important for Exam)

### **1. Existing Objects Before Versioning = **`**null**`** Version**

Objects uploaded before versioning was enabled have:

- Version ID = `null`
- Still retrievable after versioning is enabled

### **2. Suspending Versioning**

- Does **not delete** existing versions
- Simply stops creating new versions
- Safe operation

### **3. Delete Marker**

- A delete operation creates a **delete marker**
- The object appears deleted
- Previous versions still exist and can be restored

---

# 4. Versioning Diagram (Conceptual)

```plain text
Bucket (Versioning Enabled)
   ├── myfile.txt (version 1)
   ├── myfile.txt (version 2)
   ├── myfile.txt (version 3)
   └── myfile.txt (delete marker)


```

Users see the delete marker as “deleted,”

but older versions remain.

---

# 5. Summary Table

| Feature | Description |
| --- | --- |
| Bucket-level setting | Enabled or suspended on the bucket |
| Multiple versions | Each upload creates a new version |
| Delete protection | Delete marker prevents data loss |
| Rollback | Restore any previous version |
| Pre-versioning files | Have version ID = `null` |
| Suspending versioning | Keeps old versions, stops making new ones |

---

# 📌 One-Sentence Summary

> S3 Versioning stores multiple versions of objects, protects against accidental deletes, and allows easy rollback, making it an essential feature for data safety and updates.

**DELETE without versionId = Add delete marker（軟刪除）**

**DELETE with versionId = Permanently delete that version（硬刪除）**