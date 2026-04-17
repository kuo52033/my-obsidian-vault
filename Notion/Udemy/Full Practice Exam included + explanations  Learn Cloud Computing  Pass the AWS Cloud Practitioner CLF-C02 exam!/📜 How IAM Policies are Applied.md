---
notion-id: 2ac5a6e2-1812-8021-9a05-f3df5e8d70e8
---
The video explains the different ways permissions are granted using IAM policies:

- **Group Policies**: When a policy is attached to an **IAM Group** (e.g., a "Developers" group), all users within that group (Alice, Bob, Charles) automatically **inherit** those permissions.
- **Inline Policies**: You can also attach a policy directly to a single **IAM User**. This is called an **inline policy**.
- **Multiple Policies**: A user can belong to **multiple groups** (e.g., a user could be in both "Developers" and "Audit" groups). In this case, the user inherits the combined permissions from *all* the policies attached to all their groups.

## 📄 The Structure of an IAM Policy (JSON)

IAM policies are defined as **JSON documents**. The video breaks down the main components of a policy `Statement`:

- `**Effect**`: The core of the statement. This is either `**Allow**` or `**Deny**`.
- `**Principal**`: **Who** the policy applies to (e.g., a specific user, account, or role).
- `**Action**`: **What** specific API calls are being allowed or denied (e.g., `ec2:DescribeInstances` or `s3:ListBucket`).
- `**Resource**`: **Which** AWS resources the action applies to (e.g., a specific S3 bucket or EC2 instance).

The video also mentions other optional parts like `Version` (the policy language version), `Sid` (Statement ID), and `Condition` (to specify when a policy is in effect).