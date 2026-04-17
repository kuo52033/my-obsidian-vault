---
notion-id: 2cb5a6e2-1812-8070-8119-e59a1b1c2fad
---
**AWS Well-Architected Framework – CLF-002**

---

## 🎯 Definition (Exam-friendly)

**Security** is the ability to **protect data, systems, and assets** while delivering business value through:

- **Risk assessment**
- **Preventive & detective controls**
- **Automated mitigation**

> 💡 Exam mindset:
> Security ≠ cost only → **reduces long-term risk & disaster cost**

---

## 🧱 Security Design Principles (Must Remember)

### 1️⃣ Strong Identity Foundation

- Centralized identity management
- **Least Privilege** access
- Prefer **temporary credentials**

**Key services**

- IAM
- STS (temporary credentials)
- MFA
- AWS Organizations (multi-account control)

---

### 2️⃣ Enable Traceability

- Track **who did what, when**
- Monitor logs, metrics, events
- Automate responses to anomalies

**Key services**

- CloudTrail → API calls
- CloudWatch → metrics & alarms
- AWS Config → configuration compliance

---

### 3️⃣ Apply Security at All Layers

Security is **defense in depth** 👇

![](https://miro.medium.com/1%2AwYUTKw8NHxvlZ1YZ6o1NNA.png?utm_source=chatgpt.com)

![](https://d2908q01vomqb2.cloudfront.net/22d200f8670dbdb3e253a90eee5098477c95c23d/2023/11/22/img2-8.png?utm_source=chatgpt.com)

Layers to secure:

- Edge (CloudFront)
- Network (VPC, NACL, Security Groups)
- Load Balancer
- Compute (EC2, OS patching)
- Application
- Data

> CLF exam keyword: Defense in Depth

---

### 4️⃣ Automate Security Best Practices

- Security should be **automatic**, not manual
- Use managed services & IaC

Examples:

- Auto-encrypted storage
- Automated compliance checks
- Event-driven alerts

---

### 5️⃣ Protect Data (Critical Exam Topic)

### 🔐 Data In Transit

- HTTPS / SSL / TLS
- Encrypted endpoints (ALB, NLB, CloudFront)

### 🔐 Data At Rest

- Always enable encryption

| Service | Encryption |
| --- | --- |
| S3 | SSE-S3 / SSE-KMS / SSE-C |
| EBS | Encrypted volumes |
| RDS | Encrypted DB + SSL |
| KMS | Central key management |

---

### 6️⃣ Keep People Away from Data

- Avoid direct human access
- Prefer automation & roles
- Ask: **Do they really need access?**

Exam phrase:

> Reduce manual access to sensitive data

---

### 7️⃣ Prepare for Security Events

- Assume incidents **will happen**
- Practice detection & recovery

Activities:

- Incident simulations
- Automated detection
- Fast recovery (IaC)

---

## 🧰 AWS Security Services (CLF-002 Focus Map)

![](https://tse3.mm.bing.net/th/id/OIP.PiieXkkY-F0a9o-U0115ugHaEM?cb=ucfimg2&ucfimg=1&utm_source=chatgpt.com&w=474&h=379&c=7&p=0)

![](https://docs.aws.amazon.com/images/whitepapers/latest/aws-overview/images/security-identity-governance-services.png?utm_source=chatgpt.com)

### 🔑 Identity & Access

- IAM
- STS
- MFA
- AWS Organizations

---

### 🕵️ Detective Controls

| Service | Purpose |
| --- | --- |
| CloudTrail | Track API calls |
| CloudWatch | Metrics & alarms |
| AWS Config | Compliance & drift detection |

---

### 🛡️ Infrastructure Protection

| Service | Use Case |
| --- | --- |
| CloudFront | DDoS protection (edge) |
| Shield | Managed DDoS protection |
| WAF | Block malicious web traffic |
| VPC | Network isolation |
| Inspector | EC2 security assessment |

---

### 🔐 Data Protection

- KMS (encryption keys)
- S3 encryption + bucket policies
- Encrypted EBS / RDS
- HTTPS endpoints

---

## 🚨 Incident Response (Exam Favorite)

![](https://docs.aws.amazon.com/images/IDR/latest/userguide/images/idr-standard-inc-process-flow.png?utm_source=chatgpt.com)

![](https://docs.aws.amazon.com/images/IDR/latest/userguide/images/architecture.png?utm_source=chatgpt.com)

### Key Tools

- **IAM** → revoke or reduce permissions immediately
- **CloudFormation** → rebuild infrastructure
- **CloudWatch Events / EventBridge** → trigger alerts & automation

Example exam scenario:

> ❓ Someone deletes a resource
> ✅ Detect with CloudTrail → Alert via CloudWatch → Recover with CloudFormation

---

## 🧠 CLF-002 Must-Memorize Summary

### High-Frequency Keywords

- Least Privilege
- Defense in Depth
- Encryption at rest & in transit
- Automated security
- Incident response

### Quick Mapping (Exam Speed)

| Question asks about… | Answer Direction |
| --- | --- |
| API tracking | CloudTrail |
| Metrics / alarms | CloudWatch |
| Compliance | AWS Config |
| DDoS | Shield / CloudFront |
| Encryption keys | KMS |
| Rebuild infra | CloudFormation |