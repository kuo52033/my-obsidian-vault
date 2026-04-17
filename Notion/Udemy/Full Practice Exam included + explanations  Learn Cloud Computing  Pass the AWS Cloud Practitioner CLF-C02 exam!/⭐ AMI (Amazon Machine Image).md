---
notion-id: 2b05a6e2-1812-8010-8aec-eadda395fcb3
---
## 1. What Is an AMI?

An **AMI (Amazon Machine Image)** is a **preconfigured template** that defines how an EC2 instance will be created.

它代表「一台 EC2 的完整系統備份 + 設定模板」。

### AMI Includes:

| Component | Description |
| --- | --- |
| **Root Volume Template** | OS (Linux, Windows), App server, custom applications |
| **Launch Permissions** | Controls which AWS accounts can use this AMI |
| **Block Device Mapping** | Defines which EBS volumes attach to the EC2 instance |

---

# 2. Why Use AMIs?

### ✔ Faster Launch Time

All software, runtimes, libraries, and configs are already preinstalled.

### ✔ Consistent Configuration

Launch many identical EC2 instances based on the same image.

### ✔ Custom Environments

You can preconfigure:

- Monitoring tools
- Runtimes (Node, Python, Java)
- Security agents
- Custom application code

---

# 3. Types of AMIs

| Type | Description | Example |
| --- | --- | --- |
| **Public AMI** | Provided by AWS, free to use | Amazon Linux 2, Ubuntu |
| **Custom (Private) AMI** | You create it from your own EC2 | Preinstalled apps for your team |
| **Marketplace AMI** | Provided by vendors, sometimes paid | NGINX Plus, Fortinet, Datadog agent |

**Exam Tip:**

Marketplace AMIs may include **license costs** and appear on your bill.

---

# 4. AMI Lifecycle – How You Create an AMI

```plain text
[1] Launch EC2 instance
        │
        ▼
[2] Customize system
      (Install apps, configs)
        │
        ▼
[3] STOP instance (recommended)
      → Ensures data consistency
        │
        ▼
[4] Create AMI
      → This creates Snapshot(s) under the hood
        │
        ▼
[5] Launch new EC2 instances
      using this AMI
```

---

# 5. AMI + Availability Zones (AZs)

AMI 在 **一個 Region 內都可使用**（不受 AZ 限制）

但 AMI **不能跨 Region** 使用，除非你手動 **copy AMI to another Region**

## AZ Example Illustration

```plain text
Region: us-east-1
┌──────────────────────────────┐
│    AMI is stored at REGION   │
└──────────────────────────────┘
       │              │
       ▼              ▼
 us-east-1a      us-east-1b
   Launch EC2      Launch EC2
  from same AMI   from same AMI
```

✔ 同一 AMI 可跨 AZ 啟動

❌ 不能跨 Region（要 copy AMI）

---

# 6. Custom AMI Use Case Example

### Example Scenario

You launch an EC2 instance in `us-east-1a`, install:

- Node.js App
- Nginx
- Monitoring agent
- Custom configs

Then：

1. Stop instance
2. Create AMI
3. Launch new EC2 in **us-east-1b** from that AMI

→ 得到一台 **完全相同** 的系統環境

---

# 7. Additional CLF-C02 Exam Tips

### ⭐ AMIs are **Region-specific**

Must copy AMI to use in another Region.

### ⭐ Creating an AMI automatically creates **EBS Snapshots**

These snapshots store the AMI’s root volume.

### ⭐ You can control **who can launch EC2 from your AMI**

Via Launch Permissions.

### ⭐ Marketplace AMIs may incur **additional licensing cost**

Appears in billing questions.

### ⭐ Custom AMIs help achieve **scaling**

E.g., Auto Scaling Group uses AMIs to launch identical servers quickly.

---

# 📌 Final Summary (One-Shot Memorization)

> AMI = a full EC2 template → OS + apps + settings + permissions + EBS mapping.
It speeds up deployment, ensures consistency, and can be copied across Regions.
