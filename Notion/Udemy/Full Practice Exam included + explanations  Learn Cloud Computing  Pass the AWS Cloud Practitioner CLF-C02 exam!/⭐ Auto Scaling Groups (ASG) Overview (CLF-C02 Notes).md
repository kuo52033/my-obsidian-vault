---
notion-id: 2b25a6e2-1812-80a3-bd19-c0dae4ea8751
---
## 1. What Is an Auto Scaling Group?

An **Auto Scaling Group (ASG)** automatically adds or removes EC2 instances to match demand.

It works closely with Elastic Load Balancers to ensure your application is always correctly sized and healthy.

### Purpose

- **Scale out** → add EC2 instances during high demand
- **Scale in** → remove EC2 instances during low demand
- Maintain a **minimum**, **desired**, and **maximum** number of instances
- Automatically replace **unhealthy** instances
- Improve **availability** and **cost efficiency**

---

## 2. Why Use an Auto Scaling Group?

Real-world application traffic varies over time (e.g., high during the day, low at night).

ASGs let your infrastructure respond automatically.

### Benefits

- **Elasticity**: match capacity to demand
- **Fault tolerance**: replace failed instances
- **Cost savings**: run only what you need
- **Integration with Load Balancers**: automatically register/deregister instances
- **High availability**: distribute instances across multiple AZs

---

# ⭐ ASG Core Concepts

### **Minimum Capacity**

The smallest number of EC2 instances the ASG will ever run.

### **Desired Capacity**

The target number of instances (ASG tries to maintain this).

### **Maximum Capacity**

The upper limit of instances the ASG can launch.

Graphically:

```plain text
Min  →■■
Desired →■■■
Max →■■■■■■
```

The ASG will scale **between min and max**, according to demand and scaling policies.

---

# ⭐ How ASG Works with a Load Balancer

### Architecture Flow

```plain text
Clients → Load Balancer → Auto Scaling Group (EC2 instances)
```

- When ASG launches new instances → they are automatically **registered** with the LB.
- When ASG terminates instances → they are **deregistered** from the LB.
- The LB distributes incoming traffic to all healthy instances.

---

## 3. Health Management

ASG continuously monitors EC2 health.

If an EC2 instance becomes:

- Unhealthy
- Unresponsive
- Failing health checks

The ASG will:

1. Deregister the instance from the load balancer
2. Terminate it
3. Launch a **new healthy replacement**

This provides built-in **self-healing** capabilities.

---

# ⭐ Example ASG Workflow

4. **Low traffic:**
    - ASG runs 1 EC2 instance
    - LB sends all traffic to it
5. **Demand increases:**
    - ASG scales out (adds instances)
    - LB sends traffic to all registered, healthy EC2s
6. **Off-peak hours:**
    - ASG scales in (removes instances)
    - LB continues routing traffic to remaining instances

---

# ⭐ Key Exam Concepts (CLF-C02)

- **Scale Out** → add instances
- **Scale In** → remove instances
- ASGs maintain **min / desired / max** capacity
- ASGs and Load Balancers work **together**
- ASGs automatically **replace unhealthy instances**
- ASGs enable **elasticity**, one of the core cloud principles
- Improve **availability**, **fault tolerance**, and **cost optimization**

---

# 📌 One-Sentence Summary

> An Auto Scaling Group automatically adjusts the number of EC2 instances to match demand, integrates with load balancers, replaces unhealthy instances, and enables highly available and cost-optimized applications.