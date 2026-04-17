---
notion-id: 2cb5a6e2-1812-8057-95cf-f56de993bd5d
---
**AWS Well-Architected Framework – CLF-002**

---

## 🎯 Definition (Exam-friendly)

**Sustainability** focuses on **minimizing the environmental impact** of cloud workloads by:

- Understanding environmental impact
- Setting sustainability KPIs
- Continuously improving efficiency
- Achieving long-term sustainability goals (ROI)

> 💡 Exam keyword
> **Energy-efficient workloads with minimal environmental impact**

---

## 🧱 Design Principles (Must Remember)

### 1️⃣ Understand & Measure Impact

- Know how workloads consume energy/resources
- Define sustainability KPIs
- Track improvements over time

---

### 2️⃣ Maximize Resource Utilization

- Avoid idle or over-provisioned resources
- Use only what you need → **energy efficient**

Exam phrase:

> Maximize utilization to reduce waste

---

### 3️⃣ Adopt New, Efficient Hardware

- AWS continuously improves infrastructure
- Newer instance families = **better performance per watt**

Key example:

- **Graviton-based instances**

---

### 4️⃣ Prefer Managed Services

- Shared infrastructure = better efficiency
- Less duplicated resources
- Lower environmental footprint

Examples:

- Lambda, Fargate, RDS, DynamoDB

---

### 5️⃣ Reduce Downstream Impact

- Optimize services so users:
    - Consume less bandwidth
    - Need fewer device upgrades
- Reduce total energy usage end-to-end

---

## 🧰 AWS Services for Sustainability

![](https://d1.awsstatic.com/onedam/marketing-channels/website/aws/en_US/architecture/approved/images/b18be8f26412d4690b6a2b6c1a21d335-aws-sustainability-insights-framework-calculations-architecture-diagram-2334x1896.64d02d6fd4123ee76729ae92cf32609022eb07bb.png?utm_source=chatgpt.com)

### ⚙️ Compute Optimization

| Service | Sustainability Benefit |
| --- | --- |
| EC2 Auto Scaling | Match capacity to demand |
| Lambda / Fargate | Scale to zero, no idle servers |
| Spot Instances | Use spare (otherwise wasted) capacity |
| Graviton instances | Higher performance per watt |

---

### 📦 Storage Optimization

| Storage | Use Case |
| --- | --- |
| EFS-IA | Infrequent access |
| S3 Glacier | Archives |
| EBS Cold HDD | Low-access workloads |

Key idea:

> Not all data needs to be hot

---

### 🔄 Data Lifecycle Management

- **S3 Lifecycle Policies**
- **S3 Intelligent-Tiering**
- **Amazon Data Lifecycle Manager**

Goal:

- Automatically move data to the **most efficient tier**

---

### 🌍 Global & Distributed Databases

![](https://d2908q01vomqb2.cloudfront.net/887309d048beef83ad3eabf2a79a64a389ab1c9f/2024/06/20/DBBLOG-3750-2-solution-arch.png?utm_source=chatgpt.com)

| Service | Sustainability Benefit |
| --- | --- |
| RDS Read Replicas | Read locally, reduce latency |
| Aurora Global Database | Write global, read local |
| DynamoDB Global Tables | Global access, optimized routing |
| CloudFront | Cache at edge → less data transfer |

---

## 🧠 CLF-002 Must-Memorize Summary

### High-Frequency Keywords

- Energy efficiency
- Resource utilization
- Managed services
- New hardware (Graviton)
- Storage tiering
- Serverless
- Spot Instances

---

### Quick Exam Mapping

| Question Focus | Best Answer |
| --- | --- |
| Reduce environmental impact | Serverless / Managed services |
| Idle capacity waste | Auto Scaling / Spot |
| Archive data efficiently | S3 Glacier |
| Automatic storage optimization | S3 Intelligent-Tiering |
| Efficient compute | Graviton instances |
| Global low-latency access | CloudFront / Global DB |

---

## 🗺️ Mini Flowchart (Copy into Notion)

```plain text
High environmental impact?
   ↓
Measure utilization & KPIs
   ↓
Idle /over-provisioned?
   ├─ Compute → Auto Scaling / Lambda / Spot
   ├─Storage → Lifecycle / Glacier
   └─ DB →Read replicas /Globaltables
   ↓
Adopt managed services
   ↓
Continuously optimize
```

---

## 🧩 One-Sentence Exam Answer Template

> Sustainability is achieved by maximizing resource utilization, adopting managed and serverless services, using efficient hardware, and optimizing storage and data access to reduce environmental impact.