---
notion-id: 2b35a6e2-1812-808e-8520-d9ffc7c78edf
---
## 1. S3 Security Overview

Amazon S3 security is based on **user-based policies (IAM)** and **resource-based policies (Bucket Policies)**.

Only when **permissions allow** and **no explicit deny** exists does access succeed.

There are four main access control mechanisms:

| Type | Description | Common Use? |
| --- | --- | --- |
| **IAM Policies** | User-based permissions | ✔ Yes |
| **Bucket Policies** | Resource-based permissions for buckets | ✔ Most common |
| **Object ACLs** | Fine-grained per-object permissions | Rare (can be disabled) |
| **Bucket ACLs** | Legacy bucket-level ACLs | Very rare (can be disabled) |

---

# ⭐ IAM vs Bucket Policies

### IAM Policies (User-Based)

- Attached to **IAM users, roles, or groups**
- Define **what actions** the IAM principal can perform on S3
- Cannot make a bucket public

### Bucket Policies (Resource-Based)

- Attached **directly to the S3 bucket**
- Control access for:
    - IAM users in the same account
    - **Cross-account** users
    - **Public (anonymous)** access
- JSON-based documents

---

# ⭐ When Can an IAM Principal Access an S3 Object?

Access is allowed only if:

1. **IAM permissions allow**, OR
2. **Bucket policy allows**,
3. AND **no explicit deny** is present.

---

# ⭐ Bucket Policy Structure (JSON)

Example: Public read access

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::example-bucket/*"
    }
  ]
}


```

Meaning:

- `Principal: "*"` → anyone
- `Action: GetObject` → read objects
- `Resource: bucket/*` → all objects in the bucket
- Makes the entire bucket **publicly readable**

---

# ⭐ Common Bucket Policy Use Cases

| Use Case | Example |
| --- | --- |
| **Make a bucket public** | Allow `s3:GetObject` to everyone |
| **Force encryption** | Require `"s3:x-amz-server-side-encryption"` |
| **Cross-account access** | Allow another AWS account’s IAM user to access your bucket |

---

# ⭐ Access Scenarios

### 1. Public Web Access

- Bucket policy allows `Principal: "*"`
- Used for hosting static websites or public assets

### 2. IAM User Access (same account)

- IAM policy attached to the user allows S3 actions
- Bucket policy not required unless further restrictions needed

### 3. EC2 Instance Access

- Use **IAM Role** (not IAM user)
- Role’s IAM policy defines permissions
- Recommended method for applications accessing S3

### 4. Cross-Account Access

- Must use **Bucket Policy**
- Grant access to another AWS account’s IAM identity

---

# ⭐ Block Public Access (Critical Exam Topic)

S3 Block Public Access is a **safety layer** to prevent accidental data exposure.

Even if you:

- Add a Bucket Policy that makes the bucket public

If Block Public Access is **enabled**,

→ **the bucket will NOT become public**.

You can configure Block Public Access:

- At the **bucket level**
- At the **account level** (stronger)

### Purpose

- Prevent accidental public buckets
- Enterprise data protection

---

# ⭐ Summary Table

| Control | Type | Can Enable Public Access? | Typical Use |
| --- | --- | --- | --- |
| **IAM Policy** | User-based | ❌ No | Grant access to users/roles |
| **Bucket Policy** | Resource-based | ✔ Yes | Public access, cross-account access |
| **Object ACL** | Per-object | ✔ but rarely used | Legacy fine-grained control |
| **Bucket ACL** | Bucket-level | ✔ but legacy | Rarely used today |
| **Block Public Access** | Safety setting | Blocks public access | Prevent data leaks |

---

# 📌 One-Sentence Summary

> S3 security relies on IAM policies and bucket policies, with bucket policies commonly used for public access and cross-account access, while Block Public Access prevents accidental exposure.