---
notion-id: 2cb5a6e2-1812-8089-b195-daa256453d14
---
**AWS Well-Architected Framework – CLF-002**

---

## 🎯 Definition (Exam-friendly)

**Reliability** is the ability of a system to:

- **Recover from failures** (infrastructure or service)
- **Dynamically scale** to meet demand
- **Mitigate disruptions** (misconfiguration, network issues)

> 💡 Exam keyword：
> **“The system continues to work no matter what.”**

---

## 🧱 Design Principles (Must Remember)

### 1️⃣ Test Recovery Procedures

- Simulate failures using automation
- Recreate past failure scenarios
- Validate recovery works **before** real incidents

Examples:

- Fail EC2 instances
- Test DB restore
- Simulate AZ failure

---

### 2️⃣ Automatically Recover from Failure

- Detect failures early
- Self-healing systems
- No manual intervention required

Exam phrase:

> Anticipate and remediate failures automatically

---

### 3️⃣ Scale Horizontally

- Increase availability & capacity by adding resources
- Avoid vertical scaling dependency

Key concept:

- **Horizontal scaling > Vertical scaling**

---

### 4️⃣ Stop Guessing Capacity (Very Important)

- Do **NOT** manually predict capacity
- Use **Auto Scaling**

Exam trap:

> ❌ “We estimated we need 4 servers”
> ✅ “Use Auto Scaling to match demand”

---

### 5️⃣ Automate Change Management

- Infrastructure as Code (IaC)
- Safe rollbacks
- Consistent deployments

Key benefit:

- Faster recovery
- Reduced human error

---

## 🏗️ Foundations of Reliability (AWS Services)

![](https://cdn.sanity.io/images/jl67zxfh/production/98bb6d5d218aea2968fc8e8bba96ef68b6a7730c-1600x812.png?utm_source=chatgpt.com)

![](https://kodekloud.com/kk-media/image/upload/v1752860152/notes-assets/images/AWS-Certified-SysOps-Administrator-Associate-Multi-AZ-Architectures-for-Various-AWS-Services-Overview/multi-az-architecture-aws-vpc.jpg?utm_source=chatgpt.com)

### 🔐 IAM

- Prevent accidental or malicious changes
- Enforce least privilege

---

### 🌐 Amazon VPC

- Strong, isolated networking foundation
- Control traffic & fault domains

---

### 📈 Service Limits (Very Exam-relevant)

- AWS has **soft limits**
- Monitor usage as your app grows
- Request increases **before** hitting limits

Tools:

- Trusted Advisor
- Service Quotas

---

### 🧠 Trusted Advisor

- Detect approaching service limits
- Reliability best practice checks
- Cost + security insights (bonus)

---

## 🔄 Change Management

![](https://d2908q01vomqb2.cloudfront.net/b6692ea5df920cad691c20319a6fffd7a4a766b8/2021/07/05/bdb1406-image001.png?utm_source=chatgpt.com)

![](https://docs.aws.amazon.com/images/autoscaling/ec2/userguide/images/elb-tutorial-architecture-diagram.png?utm_source=chatgpt.com)

### Auto Scaling

- Automatically adjust capacity
- No manual changes needed
- Improves availability

---

### CloudWatch

- Monitor metrics (CPU, memory, latency)
- Trigger alarms
- Drive Auto Scaling decisions

---

### CloudTrail & AWS Config

| Service | Purpose |
| --- | --- |
| CloudTrail | Track API changes |
| AWS Config | Detect config drift |

---

## 🚨 Failure Management & Disaster Recovery

![](https://tse3.mm.bing.net/th/id/OIP.SuIrJueg93NkIpguEO3UZwHaEM?utm_source=chatgpt.com&w=474&h=379&c=7&p=0)

![](https://d2908q01vomqb2.cloudfront.net/fc074d501302eb2b93e2554793fcaf50b3bf7291/2021/04/23/Figure-2.-Backup-and-restore-DR-strategy.png?utm_source=chatgpt.com)

### Backups

- Regular snapshots
- Point-in-time recovery
- Critical for DR scenarios

---

### CloudFormation

- Rebuild entire infrastructure
- Fast, consistent recovery
- Core DR tool

---

### Data Storage

| Service | Use Case |
| --- | --- |
| S3 | Durable backups |
| S3 Glacier | Long-term archives |

---

### Route 53 (Global DNS – Exam Favorite)

- Highly available DNS
- Health checks
- Failover routing

Example scenario:

> Primary region fails → Route 53 points to secondary stack

---

## 🧠 CLF-002 Must-Memorize Summary

### Key Keywords

- Auto Scaling
- Multi-AZ
- Self-healing
- Service limits
- Disaster recovery
- Infrastructure as Code

---

### Quick Exam Mapping

| Question Focus | Best Answer |
| --- | --- |
| Scaling with demand | Auto Scaling |
| Capacity planning | Stop guessing capacity |
| Failure recovery | Automation + backups |
| Infra rebuild | CloudFormation |
| Global failover | Route 53 |
| Metrics monitoring | CloudWatch |
| Config tracking | AWS Config |

---

### One-Sentence Exam Answer Template

> Reliability is achieved by using automated recovery, Auto Scaling, backups, and infrastructure as code to ensure systems continue operating despite failures.