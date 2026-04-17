---
notion-id: 2b25a6e2-1812-806f-ba4c-c0816030c0dd
---
## 1. What Is a Load Balancer?

A load balancer is a server that **distributes incoming traffic across multiple backend EC2 instances**.

Users access **the load balancer**, not individual EC2 instances.

The load balancer then forwards requests to healthy backend targets.

### Benefits

- Distributes traffic across multiple EC2 instances
- Single entry point (DNS hostname) for your application
- Health checks remove unhealthy instances from rotation
- Supports SSL/TLS termination (HTTPS)
- Works across **multiple Availability Zones** → improves high availability
- Fully managed: AWS handles provisioning, upgrades, and maintenance

---

## 2. Why Use a Load Balancer?

- Improve application scalability
- Increase fault tolerance and resilience
- Simplify user access with one DNS name
- Automatically stop routing to failed instances
- Enable secure HTTPS termination
- Integrate with Auto Scaling Groups for elastic capacity

---

# ⭐ Types of AWS Load Balancers (Exam Focus)

AWS currently provides **three active load balancer types**, plus one deprecated type.

| Load Balancer | Layer | Protocols | Use Case |
| --- | --- | --- | --- |
| **Application Load Balancer (ALB)** | Layer 7 | HTTP, HTTPS, gRPC | Web applications, advanced routing |
| **Network Load Balancer (NLB)** | Layer 4 | TCP, UDP, TLS | Ultra-high performance, static IPs |
| **Gateway Load Balancer (GWLB)** | Layer 3 | GENEVE | Security appliances (firewalls, IDS/IPS) |
| **Classic Load Balancer (CLB)** | Layer 4/7 | Deprecated | Older gen, not used in exams |

---

# ⭐ Application Load Balancer (ALB)

### Key Characteristics

- **Layer 7** load balancer
- Supports **HTTP**, **HTTPS**, **gRPC**
- Offers advanced routing:
    - Path-based routing
    - Host-based routing
    - Header-based routing
    - Query string routing
- Best for web applications and microservices

### Architecture (simplified)

```plain text
User → ALB → EC2 Instances (targets)


```

---

# ⭐ Network Load Balancer (NLB)

### Key Characteristics

- **Layer 4** (TCP, UDP)
- **Very high performance** (millions of requests per second)
- Provides **static IP addresses**
- Supports Elastic IPs
- Extremely low latency
- Best for:
    - High-throughput workloads
    - Real-time systems
    - Non-HTTP protocols

### Architecture

```plain text
User (TCP/UDP) → NLB → EC2 Instances


```

---

# ⭐ Gateway Load Balancer (GWLB)

### Key Characteristics

- **Layer 3** load balancer
- Uses **GENEVE** protocol
- Specifically designed for **security appliances**:
    - Firewalls
    - Intrusion Detection Systems (IDS)
    - Deep Packet Inspection (DPI)
- Routes traffic to **security EC2 instances**, then back to the application

### Architecture (simplified)

```plain text
User Traffic → GWLB → Security Appliances (EC2) → GWLB → Application


```

Use case: inline traffic inspection at scale.

---

# ⭐ Why Managed ELB Instead of Your Own Load Balancer?

AWS manages:

- High availability
- Scaling
- Patching
- Failures
- Monitoring

Running your own load balancer on EC2 requires:

- OS management
- Scaling
- Patching
- Failover scripts
- Health checks

ELB is **cheaper, simpler, and more reliable** for most applications.

---

# ⭐ Exam Keywords Cheat Sheet

| Keyword | Load Balancer |
| --- | --- |
| HTTP, HTTPS, gRPC | **ALB** |
| Advanced routing (path/host rules) | **ALB** |
| TCP or UDP | **NLB** |
| High performance / millions RPS | **NLB** |
| Static IP needed | **NLB** |
| Firewalls / IDS / IPS | **GWLB** |
| GENEVE protocol | **GWLB** |
| Deep Packet Inspection | **GWLB** |

---

# 📌 One-Sentence Summary

> ELB is a fully managed service that distributes traffic across EC2 instances, supports multiple load balancer types, improves scalability and availability, and enables efficient handling of HTTP, TCP/UDP, and security inspection use cases.