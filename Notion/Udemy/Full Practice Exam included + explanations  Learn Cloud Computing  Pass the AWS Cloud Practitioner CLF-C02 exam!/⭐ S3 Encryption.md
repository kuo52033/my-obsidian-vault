---
notion-id: 2b45a6e2-1812-80b7-b109-e281a349b674
---
Amazon S3 supports two main models of encryption:

---

## **1. Server-Side Encryption (SSE)**

**Default behavior in all new S3 buckets.**

The object is encrypted **after it reaches AWS**.

Encryption and key management are handled by AWS.

### **How it works**

- User uploads an object → S3 automatically encrypts it before storing.
- User downloads the object → S3 decrypts it automatically.

### **SSE Variants (Know for exam)**

| Encryption Type | Description | Keys Managed By |
| --- | --- | --- |
| **SSE-S3** | Default encryption using S3-managed keys | AWS (S3) |
| **SSE-KMS** | Uses AWS KMS keys (customer-managed or AWS-managed) | AWS KMS |
| **SSE-C** | You supply the encryption key during every upload/download | Customer |

---

## **2. Client-Side Encryption**

Encryption occurs **before** the object is uploaded to S3.

### **How it works**

- The client encrypts the data locally.
- Encrypted data is uploaded as-is.
- AWS never sees the plaintext or the key.

### **Use cases**

- You must control your own encryption keys.
- Data must remain encrypted even from AWS.

---

## **Exam Tips**

- **Server-side encryption is enabled by default** on all new buckets.
- SSE-KMS introduces **KMS cost + API limits**.
- SSE-C requires you to **send the key with every request** (HTTPS mandatory).
- Client-side encryption: encryption is **fully managed by the client**.

---

# ⭐**IAM Access Analyzer for S3**

A monitoring tool that helps identify S3 buckets that are **public** or **shared with external AWS accounts**.

---

## **What It Does**

IAM Access Analyzer inspects:

- S3 bucket policies
- S3 ACLs (bucket + object ACLs)
- S3 Access Point policies
- Multi-account access configurations

It then identifies:

- Buckets with **public access**
- Buckets shared with **other AWS accounts**
- Potential **security risks**
- Cross-account access that may be unintended

---

## **Why It Matters**

- Helps prevent accidental data exposure.
- Provides continuous monitoring and findings.
- Allows you to validate whether shared access is **intended** or **misconfigured**.

---

## **Typical Use Cases**

- Detecting publicly accessible buckets.
- Ensuring compliance with security policies.
- Reviewing cross-account data sharing.