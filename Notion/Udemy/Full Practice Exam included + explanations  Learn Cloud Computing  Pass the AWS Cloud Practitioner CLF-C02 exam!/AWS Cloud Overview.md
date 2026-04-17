---
notion-id: 2ab5a6e2-1812-809c-829a-f355f21ab714
---
## 📜 A Brief History of AWS

- AWS began **internally at Amazon in 2002** when they realized their IT infrastructure was a core strength that could be externalized.
- The first public service, **Amazon SQS**, was launched in 2004.
- In **2006**, AWS officially relaunched with its three core services: **SQS (Simple Queue Service), S3 (Simple Storage Service), and EC2 (Elastic Compute Cloud)**.
- It has since expanded globally and is used by major companies like Dropbox, Netflix, and NASA.

---

## 🌎 AWS Market Position Today

- AWS is the clear market leader, holding **31%** of the cloud market (as of Q1 2024), with Microsoft Azure in second place at 25%.
- It has been named the leader in the Gartner Magic Quadrant for 13 consecutive years.
- It has over 1 million active users and generated $90 billion in revenue in 2023.

---

## 💡 What Can You Build on AWS?

You can build "pretty much everything." Common use cases include:

- Enterprise IT migration
- Backup and storage
- Big data analytics
- Website hosting
- Mobile and social application backends
- Gaming servers

---

## 🌍 The AWS Global Infrastructure

The AWS global network is built on four key components:

### 1. AWS Regions

- A **Region** is a physical, geographic location in the world (e.g., `us-east-1` in N. Virginia, `eu-west-3` in Paris) that contains clusters of data centers.
- Most AWS services are **region-scoped**, meaning resources created in one region (like an EC2 server) do not automatically exist in another.

### 2. How to Choose a Region

The video highlights four key factors for choosing the right AWS Region for your application:

1. **Compliance**: Data sovereignty or governance rules that require data to stay within a specific country (e.g., French data must stay in France).
2. **Latency**: You should choose a region that is physically close to the majority of your end-users to reduce lag.
3. **Service Availability**: Not all AWS services are available in every single region.
4. **Pricing**: The costs for services can vary from one region to another.

### 3. Availability Zones (AZs)

- An **Availability Zone (AZ)** is a component *within* an AWS Region.
- Each Region consists of multiple AZs (usually 3, with a minimum of 3 and a maximum of 6).
- An AZ is one or more **discrete data centers**, each with its own redundant power, networking, and connectivity.
- **Key Concept**: AZs are physically separate and isolated from each other. This is for fault tolerance; a disaster in one AZ (like a fire or flood) is designed *not* to affect the other AZs in that region.
- AZs within a region are connected by high-bandwidth, ultra-low-latency networking.

### 4. Points of Presence (PoPs) / Edge Locations

- AWS has over 400 **Points of Presence** (also called **Edge Locations**) globally.
- Their main purpose is to deliver content (like videos or website assets) to end-users with the **lowest possible latency**.

---

## 💡 Global vs. Region-Scoped Services

The video concludes by noting that while most services are region-scoped, a few are **Global Services**:

- **Global Services** (operate independently of regions): **IAM**, Route 53, CloudFront, WAF.
- **Region-Scoped Services** (most services): **EC2**, Elastic Beanstalk, Lambda, Rekognition.