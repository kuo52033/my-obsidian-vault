---
notion-id: 2ae5a6e2-1812-8065-ad24-d6f027d4f7f9
---
### 🛡️ IAM Overview & Core Concepts

**IAM (Identity and Access Management)** is the center of security in AWS. Here is a recap of the core components:

- **Users**: Should represent physical people (1 User = 1 Person). They use a password to access the AWS Console.
- **Groups**: Collections of users. You should attach permissions to groups, not individual users, for easier management.
- **Policies**: JSON documents that define permissions (what is allowed or denied). These are attached to users, groups, or roles.
- **Roles**: Identities intended for AWS services (like EC2 instances) to perform actions on your behalf.

---

### 🔑 Access Methods

There are different ways to interact with AWS, each requiring different credentials:

1. **AWS Console**: Accessed via **Username + Password** (and MFA).
2. **CLI (Command Line)** & **SDK (Code)**: Accessed via **Access Keys** (Access Key ID + Secret Access Key).
    - *Note:* Access Keys are as sensitive as passwords. Never share them.

---

### ✅ IAM Best Practices

To ensure your account remains secure, follow these strict guidelines:

- **Don't use the Root Account**: Only use it to set up the account initially. Afterwards, create an IAM user for yourself.
- **One User per Physical Person**: Never share credentials. If a friend needs access, create a new user for them.
- **Use Groups**: Assign users to groups and manage permissions at the group level.
- **Strong Password Policy**: Enforce minimum length, special characters, and rotation requirements.
- **Enable MFA (Multi-Factor Authentication)**: This is critical for the Root account and all IAM users to prevent hacks.
- **Use Roles for Services**: Never store access keys on an EC2 instance; use IAM Roles instead.
- **Never Share Access Keys**: Keep them secret.

---

### 🤝 Shared Responsibility Model for IAM

For the exam, it is crucial to understand who is responsible for what.

- **AWS Responsibility (Security *****of***** the Cloud)**:
    - Infrastructure security (global network, hardware).
    - Configuration and vulnerability analysis of their managed services.
    - Compliance validation.
- **Your Responsibility (Security *****in***** the Cloud)**:
    - User, Group, Role, and Policy management.
    - Enforcing MFA on all accounts.
    - Rotating Access Keys often.
    - Analyzing access patterns and auditing permissions.

---

### 🔎 Auditing & Monitoring

You are responsible for auditing your account's security. AWS provides two key tools for this:

3. **IAM Credentials Report**: A report that lists all your account's users and the status of their various credentials (passwords, access keys, MFA status).
4. **IAM Access Advisor (now is called Last Accessed)**: A feature that shows the service permissions granted to a user and when those services were last accessed. This helps verify if users have more permissions than they actually need.