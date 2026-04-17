---
notion-id: 2af5a6e2-1812-8045-aa5e-cc392f73926a
---
Security Groups (SGs) are a **fundamental security layer** in AWS and act as **virtual firewalls** that control traffic **into** (inbound) and **out of** (outbound) your EC2 instances.

---

# **1. What Security Groups Do**

- They **control which traffic is allowed** to reach your EC2 instance (inbound) and which traffic your instance is allowed to send out (outbound).
- **Security groups only contain ALLOW rules** — no deny rules.
- If something is *not* explicitly allowed, it is automatically denied.

### **Exam Tip**

> AWS Security Groups = “Default deny. Allow-only rules.”

---

# **2. How Security Groups Handle Traffic**

Security Group rules specify:

- **Type** (e.g., SSH, HTTP)
- **Protocol** (usually TCP)
- **Port range**
- **Source** (IPv4, IPv6, or another SG)

Special sources:

- `0.0.0.0/0` → any IPv4 address
- `::/0` → any IPv6 address
- A specific IP → e.g., `87.14.54.201/32`
- **Another Security Group** → server-to-server trusted traffic

---

# **3. Inbound vs Outbound Rules**

### **Inbound**

Controls what can reach the EC2 instance.

Example:

If inbound rule allows SSH on port 22 from your IP, **only you** can SSH into the instance.

If another computer tries, it will fail (timeout).

### **Outbound**

By default, **all outbound traffic is allowed**.

This means EC2 can access the Internet unless you restrict it.

### **Exam Tip**

> If you get TIMEOUT → inbound SG issue.
> **If you get CONNECTION REFUSED → app is running incorrectly but SG allowed traffic.**

---

# **4. How SGs Behave**

- They are **stateful**:
    - If inbound traffic is allowed, **response traffic is automatically allowed** regardless of outbound rules.
- They exist **outside** the EC2 instance.
    - If traffic is blocked, the instance never sees it.
- An EC2 instance can have **multiple SGs**.
- A single SG can be attached to **multiple EC2 instances**.
- SGs are **regional** and **VPC-specific**.
    - Changing region or VPC requires recreating SGs.

### **Exam Tip**

> NACLs = Stateless
> Security Groups = Stateful
> 
> (They love asking this!)

---

# **5. Referencing Security Groups (SG-to-SG rules)**

A more advanced but powerful feature:

Example:

- SG1 allows inbound traffic from SG2.
- Any EC2 with SG2 can reach EC2s with SG1 — **no need to manage IPs**.

This is extremely useful for:

- Load balancers → web servers
- Web servers → backend servers
- Microservice-to-microservice communication

### **Exam Tip**

> SG-to-SG referencing is the correct way to allow internal service communication without opening public IP ranges.

---

# **6. Classic Ports You MUST Memorize (HIGH EXAM PRIORITY)**

| Protocol | Port | Purpose |
| --- | --- | --- |
| **SSH** | **22** | Login to Linux EC2 instances |
| **SFTP** | **22** | Secure file transfer (over SSH) |
| **FTP** | 21 | Unsecured file transfer |
| **HTTP** | 80 | Unencrypted web traffic |
| **HTTPS** | 443 | Secure web traffic |
| **RDP** | **3389** | Remote Desktop to Windows EC2 |

### **Exam Tip**

These ports WILL appear in CCP/SAA questions.

Especially SSH (22), HTTP (80), HTTPS (443), RDP (3389).

---

# **7. Best Practices (Real World + Exam-Relevant)**

### **Keep a dedicated SG for SSH**

- Easy to reuse and control.
- Keeps your SSH access clean and secure.

### **Open ports only when required**

AWS exams frequently test:

- “Your application is not reachable”
→ usually missing inbound SG rule.

### **Default behavior**

- **Inbound:** everything blocked
- **Outbound:** everything allowed

---

# **8. Common Troubleshooting Behavior**

### **Timeout → SG Problem**

Traffic never reached the instance.

### **Connection Refused → Application Problem**

SG allowed it, but the application didn’t accept it.

---

# ✔ Summary Table — Security Groups Knowledge

| Topic | Key Point |
| --- | --- |
| SG Rule Type | Allow only |
| Default inbound | Blocked |
| Default outbound | Allowed |
| Firewall position | Outside EC2 |
| Stateful? | Yes |
| Attached to | EC2 ENIs (network interface) |
| Reuse | Many EC2s can share |
| Cross-region? | No (regional only) |