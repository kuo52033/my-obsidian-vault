---
notion-id: 2ab5a6e2-1812-8081-bee0-f9d0e6f2a67f
---
The video explains the three main types of cloud computing, which are important to distinguish:

- **IaaS (Infrastructure as a Service)**
    - **What it is:** Provides the fundamental **building blocks** for cloud IT, such as raw networking, computers (virtual servers), and data storage space.
    - **Analogy:** It's like being given LEGOs. It offers the highest level of flexibility.
    - **AWS Example:** Amazon EC2.
- **PaaS (Platform as a Service)**
    - **What it is:** Removes the need for you to manage the underlying infrastructure (like the OS or servers). You just **focus on deploying and managing your applications**.
    - **AWS Example:** AWS Elastic Beanstalk.
- **SaaS (Software as a Service)**
    - **What it is:** A **completed product** that is run and managed entirely by the service provider. You simply use the software.
    - **Examples:** AWS Rekognition, or common applications like **Gmail**, **Dropbox**, and **Zoom**.

---

## sorumluluk Comparison

The video illustrates the difference by showing who manages what in each model:

- **On-Premises**: **You manage everything**, from the physical servers and networking all the way up to your application and data.
- **IaaS**: **You manage** the Operating System (OS), middleware, runtime, data, and applications.
    - *AWS manages:* The underlying virtualization, servers, storage, and networking.
- **PaaS**: **You manage** only your **Application** and your **Data**.
    - *AWS manages:* Everything else (runtime, middleware, OS, servers, etc.).
- **SaaS**: **AWS (or the provider) manages everything**.

---

## 💰 AWS Pricing Fundamentals

The video also covers the core pricing model for AWS, which is **pay-as-you-go**.

This model is broken down into three parts:

1. **Compute**: You pay for the **exact compute time** you use.
2. **Storage**: You pay for the **exact amount of data** you store.
3. **Networking**: You pay *only* for data that **leaves the cloud** (data going *into* the cloud is free).

This pricing model is what solves the high-cost issue of traditional IT, allowing for "huge cost savings" because you only pay for what you actually use.