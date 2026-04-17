---
notion-id: 2b15a6e2-1812-8059-b113-e45f8f9a66c2
---
## 1. Scalability Overview

Scalability refers to a system’s ability to handle increased load.

There are **two types of scalability** in the cloud:

---

## 2. Vertical Scalability (Scale Up / Scale Down)

### Definition

Increasing the size or capacity of a single server.

### Analogy

Upgrading a junior operator to a senior operator who can handle more calls.

### AWS Example

- Moving from **t2.micro** → **t2.large**
- Typical for non-distributed systems (e.g., databases)

### Characteristics

- Simple approach
- Limited by hardware maximums
- No change in the number of servers

---

## 3. Horizontal Scalability (Scale Out / Scale In)

### Definition

Increasing the number of servers instead of increasing server size.

### Analogy

Adding more call center operators to handle additional calls.

### AWS Example

- Adding multiple EC2 instances behind a Load Balancer
- Implemented using **Auto Scaling Groups**

### Characteristics

- Requires distributed system design
- Very common with web applications and cloud-native architectures

---

## 4. High Availability (Multi-AZ)

### Definition

Running your application across **multiple Availability Zones**, ensuring it continues operating even if one AZ fails.

### Analogy

A call center with two physical offices (New York and San Francisco).

If one goes down, the other continues taking calls.

### AWS Implementation

- Launch EC2 instances across at least **two Availability Zones**
- Use **Auto Scaling Groups (multi-AZ)** + **Load Balancers (multi-AZ)**

### Benefits

- Survives data center-level disasters (power outage, natural disaster)
- Reduces single points of failure

---

## 5. Summary Table: Scaling Types

| Concept | How It Works | AWS Tools | Example |
| --- | --- | --- | --- |
| **Vertical Scaling** | Increase instance size | EC2 instance types | t2.micro → t2.large |
| **Horizontal Scaling** | Increase number of instances | Auto Scaling Group | Add more EC2 instances |
| **High Availability** | Multi-AZ deployment | ASG (multi-AZ), ELB | Instances in AZ1 + AZ2 |

---

## 6. Scaling Vocabulary (Exam Keywords)

### **Scalability**

A system’s ability to handle more load by:

- Scaling **up** (bigger instance)
- Scaling **out** (more instances)

### **Elasticity**

Automatically adjusting capacity based on demand.

Elasticity implies **auto scaling**.

> Pay only for what you use; match capacity to workload in real time.

### **Agility** (Distractor Term)

Not related to scaling.

Means AWS resources are quick to provision → improve development speed.

---

## 7. Terms: Scale Up/Down vs Scale Out/In

| Action | Meaning |
| --- | --- |
| **Scale Up** | Increase instance size |
| **Scale Down** | Decrease instance size |
| **Scale Out** | Add more instances |
| **Scale In** | Remove instances |

---

# 📌 One-Sentence Summary

> Vertical scalability increases instance size, horizontal scalability increases instance count, high availability uses multiple AZs, and elasticity means automatic scaling based on demand.