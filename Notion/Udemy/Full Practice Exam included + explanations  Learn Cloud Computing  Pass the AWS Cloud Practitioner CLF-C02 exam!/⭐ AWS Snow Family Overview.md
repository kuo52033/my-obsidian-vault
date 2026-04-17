---
notion-id: 2b45a6e2-1812-80dc-bf2a-d647d641d307
---
The AWS Snow Family consists of **offline, portable, and highly secure devices** designed for two major use cases:

1. **Large-scale data migration** (into or out of AWS)
2. **Edge computing** in environments with limited or no internet connectivity

The Snow Family includes:

- **Snowball Edge Storage Optimized**
- **Snowball Edge Compute Optimized**
- (Other devices like Snowcone exist, but exams focus mainly on Snowball Edge)

---

# Snowball Edge Device Types

| Device Type | Primary Use | Storage Capacity | Compute Capability |
| --- | --- | --- | --- |
| **Snowball Edge Storage Optimized** | Large-scale data transfer | ~210 TB usable | Limited compute |
| **Snowball Edge Compute Optimized** | Edge computing workloads | ~28 TB usable | Powerful compute resources (supports EC2 + Lambda functions) |

---

# Why Snowball? (Data Migration Motivation)

Transferring data over the internet can be slow, expensive, or unreliable.

For example:

- **100 TB over a 1 Gbps link → ~12 days of continuous transfer**
- Bandwidth may be limited, shared, or unstable
- Network egress costs can be high

**If data transfer takes more than a week over your network, AWS recommends using Snowball.**

---

# How Snowball Data Migration Works

3. **Order the Snowball device** from AWS.
4. AWS ships a physical hardened appliance to your location.
5. **You copy data** into the device using encryption and client tools.
6. **Ship the device back** to AWS using the built-in e-ink shipping label.
7. AWS uploads the data into your S3 bucket.

This avoids:

- Network bottlenecks
- High bandwidth costs
- Long transfer delays

---

# Snowball for Edge Computing

Snowball Edge devices can run compute workloads in disconnected or remote environments.

### Key Capabilities

- Run **EC2 instances** directly on the device
- Run **AWS Lambda functions** locally
- Process, filter, or transform data before uploading it to AWS
- Operates in rugged, offline, or bandwidth-limited locations

### Typical Use Cases

- Industrial sites (mining, factories)
- Ships at sea
- Remote scientific stations
- Military and tactical deployments
- Vehicles (trucks, aircraft)

---

# Exam Tips

- **Snowball is for petabyte-scale data transfer or offline processing.**
- If network transfer takes **more than a week**, choose Snowball.
- **Snowball Edge Compute Optimized** is used for **local compute**, not just storage.
- All data on Snowball devices is **encrypted with KMS-managed keys**.
- Snowball devices are **rugged, tamper-resistant**, and shipped in secure containers.