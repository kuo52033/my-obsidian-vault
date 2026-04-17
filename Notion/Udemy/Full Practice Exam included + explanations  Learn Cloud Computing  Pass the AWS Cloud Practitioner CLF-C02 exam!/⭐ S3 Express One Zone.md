---
notion-id: 2b45a6e2-1812-80e3-8e34-ca7e8f1f1bc3
---
**Amazon S3 Express One Zone** is a *high-performance*, *single-Availability Zone* storage class designed for workloads that require extremely low latency and very high request rates.

---

## **Key Characteristics**

### **1. Stored in a Single Availability Zone**

- Objects are stored **only in one AZ**, unlike standard S3 buckets which replicate across multiple AZs.
- Stored in **Directory Buckets**, a special type of S3 bucket designed for this performance tier.

### **2. Extremely High Performance**

- Up to **10× the performance** of S3 Standard.
- Supports **hundreds of thousands of requests per second**.
- Latency in **single-digit milliseconds**.
- About **50% lower cost** compared to S3 Standard.

### **3. Durability & Availability**

- High durability but **lower availability** than multi-AZ storage classes.
- If the AZ fails, the data becomes unavailable (or lost depending on the failure type).

### **4. AZ-Level Data Locality**

- Optimized for **co-locating compute and storage** in the same Availability Zone.
- Reduces:
    - Latency
    - Cross-AZ data transfer costs
    - End-to-end processing time

---

## **Use Cases**

- **Latency-sensitive applications**
- **Data-intensive workloads**
- **AI/ML training pipelines**
- **ETL / big data processing**
- **Financial modeling**
- **Media rendering and processing**
- **High Performance Computing (HPC)**

---

## **Best Integrations**

S3 Express One Zone works especially well with compute-heavy AWS services such as:

- **AWS SageMaker (model training)**
- **Amazon EMR**
- **AWS Glue**
- **Amazon Athena**
- **Custom EC2 or ECS compute clusters**

---

## **When to Use It**

Choose S3 Express One Zone when:

✔ You need the **fastest possible object storage** access on AWS

✔ You can tolerate **single-AZ storage**

✔ Your compute is in the **same AZ**

✔ You want **extreme throughput + low latency**

✔ Your workload frequently hits **very high request rates**

---

## **When NOT to Use It**

Avoid S3 Express One Zone when:

✖ You require multi-AZ durability

✖ Your workload cannot tolerate AZ failures

✖ You don’t need ultra-low latency or high request throughput

✖ Your compute spans multiple AZs