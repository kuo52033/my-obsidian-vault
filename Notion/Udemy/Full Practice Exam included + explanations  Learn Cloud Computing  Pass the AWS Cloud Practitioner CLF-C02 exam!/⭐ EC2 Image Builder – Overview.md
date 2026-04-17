---
notion-id: 2b05a6e2-1812-80d7-97a6-e133ba5d5b79
---
## 1. What Is EC2 Image Builder?

**EC2 Image Builder** is an AWS service that lets you **automate the creation, maintenance, validation, and testing of AMIs** (and container images).

purpose：

> Automatically build, test, and update AMIs on a schedule.

---

# 2. Why Use EC2 Image Builder?

| Benefit | Description |
| --- | --- |
| **Automation** | No more manually building AMIs |
| **Consistency** | Ensures all images are standardized |
| **Security** | Automatically updates and patches software |
| **Testing** | Verify AMI health before production use |
| **Multi-Region Distribution** | Automatically copy AMIs to multiple regions |
| **Costs only underlying resources** | The service itself is free |

---

# 3. How EC2 Image Builder Works (Flow Diagram)

```plain text
                ┌─────────────────────────┐
                │    EC2 Image Builder    │
                └─────────────┬───────────┘
                              │
                              ▼
                   (1) Builder EC2 Instance
                  ┌────────────────────────┐
                  │ Install components:    │
                  │ - OS patches           │
                  │ - CLI updates          │
                  │ - Security tools       │
                  │ - App installation     │
                  └─────────────┬──────────┘
                                │
                                ▼
                       (2) Create AMI
                                │
                                ▼
                   (3) Test EC2 Instance Created
                  ┌─────────────────────────┐
                  │ Runs validation tests:  │
                  │ - Is AMI booting?       │
                  │ - Is app running?       │
                  │ - Security checks       │
                  └─────────────┬───────────┘
                                │
                                ▼
                   (4) Distribute AMI
             (Copy to multiple Regions if needed)


```

---

# 4. EC2 Image Builder Workflow (Step-by-Step)

### **Step 1 – Builder EC2 Instance**

Image Builder automatically launches an EC2 instance called a **builder instance**.

This instance will:

- Install software
- Update system packages
- Apply security hardening
- Install firewalls
- Install your application

Everything is configured according to your **image recipe**.

---

### **Step 2 – Create AMI**

After customization completes →

Image Builder **automatically creates an AMI**.

✔ This is similar to clicking “Create Image” manually, but fully automated.

---

### **Step 3 – Validation Tests**

Image Builder launches a **test EC2 instance** using the newly created AMI.

- Boot verification
- App health checks
- Security tests
- Any custom tests

✔ Tests are optional (you can skip them)

---

### **Step 4 – Distribution**

Once tests pass, Image Builder can:

- Distribute AMI to **multiple Regions**
- Share AMI with other accounts
- Put images into production workflows

---

# 5. Automation and Scheduling

You can schedule Image Builder pipelines to run:

| Schedule Type | Description |
| --- | --- |
| **Weekly / Monthly** | e.g., auto-build AMI every week |
| **On package updates** | Trigger when new OS patches become available |
| **Manual on-demand** | Trigger anytime |

This ensures your AMIs always have the latest updates & patches.

---

# 6. Pricing

| Component | You pay for | Notes |
| --- | --- | --- |
| EC2 Builder Instance | EC2 usage time | Used during image building |
| EC2 Test Instance | EC2 usage time | Used for validation |
| AMI Storage | Snapshot storage | Stored in S3 internally |
| Multi-Region Copies | Storage in each region | AMIs copied to regions |

✔ The **Image Builder service itself is free**.

You only pay for the compute and storage the pipeline uses.

---

# 7. CLF-C02 Exam-Focused Summary

### ⭐ EC2 Image Builder is for:

- Automating AMI creation
- Keeping AMIs updated and secure
- Running validation tests
- Distributing AMIs across Regions

### ⭐ Image Builder automatically:

- Launches a **builder instance**
- Launches a **test instance**
- Creates AMIs
- Copies AMIs across Regions
- Runs on a **schedule**

### ⭐ Image Builder is **free**, but:

> You pay for EC2 instances and AMI storage used during the process.

---

## 📌 One-Sentence Summary

> EC2 Image Builder automates building, updating, testing, and distributing AMIs across Regions, ensuring consistent, secure, and up-to-date EC2 images.