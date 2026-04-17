---
notion-id: 2b35a6e2-1812-8076-a2a8-f46f44a7c01f
---
Amazon S3 can host **static websites**, making it possible to serve HTML, CSS, JS, images, and other static assets directly from an S3 bucket.

---

## 1. What Is a Static Website on S3?

A **static website**:

- Does *not* support server-side code (no PHP, Node.js, Python, etc.)
- Only serves files such as:
    - HTML
    - CSS / JS
    - Images, videos, documents

S3 provides a **website endpoint URL**, which depends on the region and follows one of these formats:

```plain text
http://<bucket-name>.s3-website-<region>.amazonaws.com
http://<bucket-name>.s3-website.<region>.amazonaws.com
```

(The difference is simply dash vs dot notation.)

---

## 2. Requirements for S3 Website Hosting

To enable static website hosting, you must:

### **1. Enable Static Website Hosting in the bucket**

- Select an index document (e.g., `index.html`)
- Optional: define an error document (e.g., `error.html`)

### **2. Make the bucket public**

S3 website hosting requires **public read access**.

Otherwise, users accessing the website will get:

```plain text
403 Forbidden


```

To allow public access:

- Attach a **Bucket Policy** that allows `s3:GetObject`
- Ensure **Block Public Access** is disabled (at least for this bucket)

Example public-read bucket policy:

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

---

## 3. Architecture Overview

```plain text
User (Browser)
      ↓
S3 Website Endpoint URL
      ↓
Public Objects in S3 Bucket (HTML, CSS, JS, Images)


```

- No authentication
- No HTTPS (unless fronted by CloudFront)
- Files must be publicly readable

---

## 4. Common Errors

### **403 Forbidden**

Cause:

- Bucket is not public
- Missing or incorrect bucket policy
- Block Public Access still enabled

Fix:

- Add public-read bucket policy
- Disable Block Public Access

---

# ⭐ Summary Table

| Feature | Description |
| --- | --- |
| Static Website Hosting | Serves static content directly from S3 |
| Website Endpoint | Region-specific HTTP URL |
| Public Access Required | Must enable `s3:GetObject` for everyone |
| Block Public Access | Must be disabled for the bucket |
| Typical Use Cases | Personal sites, docs, static assets, landing pages |

---

# 📌 One-Sentence Summary

> S3 can host static websites by enabling website hosting and making the bucket publicly readable; without a public bucket policy, the site will return “403 Forbidden.”