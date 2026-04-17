---
notion-id: 2b05a6e2-1812-8025-972b-cb9e1b83b8d7
---
## 1. AWS Responsibilities

AWS is responsible for all **infrastructure-level** tasks related to EC2 storage.

### **Infrastructure & Hardware**

- Maintaining the physical servers and storage devices.
- Replacing faulty hardware when failures occur.

### **Data Replication**

- For services like **EBS** and **EFS**, AWS handles internal data replication to ensure durability and reliability.
- Ensures that hardware failure within the AWS data center does **not** cause customer data loss.

### **Security of the Cloud**

- Ensuring AWS employees cannot access customer data.
- Maintaining secure infrastructure, access control, and isolation across tenants.

---

## 2. Customer Responsibilities

Customers are responsible for everything **in the cloud**, including the data and configuration they choose to implement.

### **Backup & Recovery**

- Creating and managing **snapshots**, **backups**, and **retention policies**.
- Ensuring data is protected according to business requirements.

### **Data Encryption**

- Enabling encryption for EBS, EFS, or other storage as needed.
- Managing encryption keys (unless using AWS-managed keys).

### **Data Lifecycle & Management**

- Managing what data is stored and how it is used.
- Ensuring compliance with internal policies and regulations.

### **Instance Store Awareness**

For **Instance Store** (ephemeral storage):

- Understanding that data is **lost** when:
    - The EC2 instance stops
    - The instance terminates
    - The underlying physical host fails
- Implementing backup mechanisms if using Instance Store.

---

## 3. Quick Comparison Table

| Responsibility Area | AWS | Customer |
| --- | --- | --- |
| Physical infrastructure | ✔ | — |
| Hardware maintenance | ✔ | — |
| Internal replication (EBS/EFS) | ✔ | — |
| Preventing AWS employee data access | ✔ | — |
| Configuring backups & snapshots | — | ✔ |
| Enabling data encryption | — | ✔ |
| Managing data stored on volumes | — | ✔ |
| Handling Instance Store ephemeral behavior | — | ✔ |

---

## ⭐ Exam Key Takeaways (CLF-C02)

- AWS handles **hardware, replication, and secure infrastructure**.
- Customer handles **data protection, backups, encryption, and configuration**.
- Instance Store is **customer risk** → data loss unless backed up.
- Shared Responsibility = **AWS secures the cloud; customer secures their data in the cloud**.