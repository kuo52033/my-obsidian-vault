---
notion-id: 2af5a6e2-1812-8045-aff7-c5937d6dde12
---
**Concept:** Security in the cloud is shared between **AWS** and **you (the customer)**.

| Responsibility | Details |
| --- | --- |
| **AWS (Security *****of***** the Cloud)** | - Physical data centers- Hardware & networking infrastructure- Isolation of physical hosts (dedicated hosts)- Replacing faulty hardware- Compliance with regulations |
| **Customer (Security *****in***** the Cloud)** | - EC2 instance security (OS & software)- Security group rules (firewall control)- Operating system patches & updates (Linux/Windows)- Installed software & utilities- IAM roles & permissions- Data security on the instance |

**Exam Tip:**

- Know the difference: AWS secures the *physical infrastructure*, you secure your *virtual machines and data*.
- Always use **IAM roles** for EC2 instead of embedding keys in instances.

---

**Key Components of an EC2 Instance:**

1. **AMI (Amazon Machine Image)**
    - Defines the operating system and base configuration of the instance.
2. **Instance Type / Size**
    - Defines CPU, RAM, network performance.
3. **Storage**
    - EBS or Instance Store (network-attached vs hardware-attached).
4. **Security Groups**
    - Firewalls controlling inbound/outbound traffic.
    - Rules define allowed ports and source IPs.
    - Stateful: outbound rules default allow, inbound default deny.
5. **User Data / Bootstrap Scripts**
    - Script executed when the instance first starts (e.g., set up web server).
6. **SSH / EC2 Instance Connect**
    - Connect to Linux instances (port 22).
    - Windows RDP (port 3389).
7. **EC2 Instance Role**
    - Assign IAM roles to instances for AWS API access.
    - Avoid storing access keys in EC2.

**Purchasing Options (Exam Focus):**

| Option | Use Case | Notes |
| --- | --- | --- |
| **On-Demand** | Short-term, unpredictable workloads | Highest cost, most flexible |
| **Reserved Instances (RI)** | Long-term, steady workloads | Up to 72% discount |
| **Convertible RI** | Long-term, may change instance type | Up to 66% discount |
| **Savings Plan** | Long-term, flexible instance usage | Discount based on committed spend |
| **Spot Instances** | Fault-tolerant, flexible workloads | Up to 90% discount, can be terminated anytime |
| **Dedicated Host** | Compliance / BYOL | Full physical server, most expensive |
| **Dedicated Instance** | Higher isolation without full host | Shares physical host with other instances from same account |

**Exam Tips:**

- Understand **which purchase option fits which workload**.
- Remember EC2 instance security and networking are **customer’s responsibility**, but AWS handles underlying infrastructure.
- Know ports and protocols: **SSH 22**, **HTTP 80**, **HTTPS 443**, **RDP 3389**.

How long can you reserve an EC2 Reserved Instance? 1 or 3 years