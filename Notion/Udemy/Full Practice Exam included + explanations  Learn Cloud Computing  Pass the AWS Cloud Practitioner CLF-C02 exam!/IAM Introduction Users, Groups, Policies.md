---
notion-id: 2ac5a6e2-1812-8054-a4bf-e677ffb157e1
---
## 🔑 What is IAM (Identity and Access Management)?

- **IAM** stands for **Identity and Access Management**.
- It is a **Global Service**, meaning its configurations (users, groups) apply across all AWS regions.

---

## 👤 The Root User

- When you first create an AWS account, you are using the **Root User**.
- This user has complete and unrestricted access to the entire account.
- **Best Practice**: You should **only** use the Root User for initial account setup. You should **not** use it for everyday tasks or share it.

---

## 🧑‍💼 IAM Users

- Instead of using the Root User, you should create **IAM Users**.
- An IAM User represents a single person or service within your organization (e.g., Alice, Bob).

## 👨‍👩‍👧‍👦 IAM Groups

- An **IAM Group** is a collection of IAM Users. This simplifies permission management.
- **Example**: You can create a "Developers" group for Alice, Bob, and Charles, and an "Operations" group for David and Edward.
- **Key Rules**:
    - Groups can only contain **users**.
    - Groups **cannot** contain other groups.
    - A user **can** belong to multiple groups (e.g., Charles could be in both "Developers" and "Audit" groups).

---

## 📜 IAM Policies (Permissions)

- **IAM Policies** are what grant permissions to users or groups.
- These policies are defined in a **JSON document**.
- The JSON file explicitly states what actions are allowed (or denied) on which AWS services (e.g., allow "Describe" actions on "EC2").

## 🔒 The Least Privilege Principle

- The video emphasizes the single most important concept in IAM: the **Least Privilege Principle**.
- This means you should **never** give users more permissions than they absolutely need to do their job.
- This prevents costly mistakes and major security vulnerabilities.