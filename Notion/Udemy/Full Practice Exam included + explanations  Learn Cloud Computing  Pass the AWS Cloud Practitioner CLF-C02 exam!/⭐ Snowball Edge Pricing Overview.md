---
notion-id: 2b45a6e2-1812-8077-9dba-f11241f93fc1
---
## Pricing Components

Snowball Edge pricing consists of two major cost areas:

### **1. Data Transfer Costs**

- **Data *****into***** Amazon S3 via Snowball Edge → $0/GB (Free)**
Uploading data from the Snowball Edge into S3 does *not* incur data transfer charges.
- **Data *****out of***** AWS onto a Snowball device → Charged per GB**
Exporting data from AWS to a Snowball Edge device incurs standard data transfer-out costs.

---

## **2. Device Usage Pricing**

There are two pricing models for the device itself:

---

### **A. On-Demand Pricing (Per Job)**

You pay a one-time service fee per Snowball job.

This fee includes a **number of usage days**, depending on the device:

| Device Type | Included Usage | Notes |
| --- | --- | --- |
| Snowball Edge Storage Optimized (80 TB) | 10 days | Usage days start after arrival, not including shipping |
| Snowball Edge Storage Optimized (210 TB) | 15 days | Same rule: shipping time does not count |

After the included days:

- You pay a **per-day fee** for additional usage.

**Shipping to/from AWS is free** and does not count toward your usage days.

---

### **B. Committed Upfront Pricing**

For long-term edge computing use cases.

- Commit monthly, 1-year, or 3-year usage.
- Provides **up to 62% discount** vs on-demand.
- Ideal for:
    - Continuous edge analytics
    - Long-term offline compute environments
    - Replacing servers in remote sites

---

## Exam Tips

- **Data uploaded into S3 via Snowball → Always free.**
- You pay for:
    - **Device usage (service fee + extra day charges)**
    - **Data exported from AWS onto Snowball**
- Shipping is **included at no cost**.
- Committed-upfront pricing = **discounted long-term compute usage**.