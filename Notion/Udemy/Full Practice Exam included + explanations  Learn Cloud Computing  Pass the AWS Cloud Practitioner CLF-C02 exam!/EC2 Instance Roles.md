---
notion-id: 2af5a6e2-1812-8090-b057-e5ae71f6d150
---
## **1. Why We Use IAM Roles on EC2**

IAM Roles allow an EC2 instance to call AWS services **securely**, **without storing any credentials** on the server.

✔ Best practice

✔ Secure

✔ Automatically rotated temporary credentials

✔ Required knowledge for ALL AWS exams

---

# **2. NEVER store access keys on EC2**

When you SSH or EC2 Instance Connect into your EC2 instance, you might try:

```plain text
aws configure
```

This asks for:

- Access Key ID
- Secret Access Key

❌ **Never enter your personal credentials inside an EC2 instance.**

Why it’s dangerous:

- Anyone who gains access to the instance could steal your keys.
- These keys could then be used to access your AWS account.
- Exam frequently tests this as a “Bad Practice”.

👉 **Correct practice: Use IAM Roles instead.**

---

# **3. What an IAM Role Does**

An IAM role gives your EC2 instance **temporary credentials** through the Instance Metadata Service (IMDS).

EC2 automatically receives:

- Access Key
- Secret Key
- Session Token
(all temporary)

So EC2 can execute AWS CLI commands like:

```plain text
aws iam list-users
aws s3 ls
aws dynamodb scan


```

depending on the permissions attached to the role.

---

# **4. Attaching an IAM Role to an EC2 Instance**

Steps (important for exam):

1. Go to **IAM → Roles**
2. Create a role with **trusted entity = EC2**
3. Attach a policy (e.g., `IAMReadOnlyAccess`)
4. Go to **EC2 → Instances → Actions → Security → Modify IAM Role**
5. Attach the role to the instance

Now:

```plain text
aws iam list-users


```

✔ Works (no keys needed)

If you detach the policy:

✔ Access denied (expected)

---

# **5. IAM Role Effects Are Immediate, but Sometimes Need Seconds to Propagate**

When attaching or modifying role policies:

- Small delay (a few seconds)
- Exam may ask about this

---

# **6. EC2 Instance Connect**

EC2 Instance Connect:

- Works through the browser
- Requires an Amazon Linux 2 AMI
- No need to store private keys locally

Does NOT affect IAM roles—it’s only for login convenience.

---

# **7. Exam Must-Know: IAM Roles vs Instance Profiles**

AWS exam terminology:

| Term | Meaning |
| --- | --- |
| **IAM Role** | Set of permissions (+ trust policy) |
| **Instance Profile** | The container that attaches the IAM Role to EC2 |

✔ Instance Profiles are required for EC2

✔ AWS Console handles this automatically

✔ In the exam, they might explicitly mention them

---

# **8. IAM Role Exam Tips (High Probability Questions)**

### **❗Q1: Should you store AWS credentials on an EC2 instance?**

👉 **Never. Always use IAM Roles.**

### **❗Q2: How does the instance receive credentials?**

👉 Through the **Instance Metadata Service (IMDS)**, automatically.

### **❗Q3: If an EC2 instance cannot access S3, but it has a role—what to check?**

- Check if the role has the correct **policy** attached.
- Check if you accidentally attached the role to the wrong instance.

### **❗Q4: If you detach a policy from the role, what happens?**

👉 The instance immediately loses permission, after slight propagation delay.

---

# **9. Example CLI Behavior**

Before attaching role:

```plain text
aws iam list-users
→ Unable to locate credentials


```

After attaching role:

```plain text
aws iam list-users
→ Works


```

After removing policy:

```plain text
aws iam list-users
→ AccessDenied


```

---

# **10. Why This Matters**

IAM roles are the **only secure and recommended** method for applications on EC2 to authenticate with AWS.

This is a **core exam topic** for:

- AWS Cloud Practitioner (CLF-C02)
- AWS Solutions Architect Associate (SAA-C03)
- AWS Developer Associate
- AWS SysOps Administrator