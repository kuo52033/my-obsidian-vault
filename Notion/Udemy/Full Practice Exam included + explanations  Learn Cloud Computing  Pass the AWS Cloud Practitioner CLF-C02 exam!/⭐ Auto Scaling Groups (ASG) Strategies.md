---
notion-id: 2b25a6e2-1812-8071-bfb9-fd432a2cbc29
---
Auto Scaling Groups support multiple scaling strategies to match different application needs.

These strategies help maintain optimal performance and cost efficiency as load fluctuates.

---

# 1. Manual Scaling

You manually adjust the **desired**, **minimum**, or **maximum** capacity of the ASG.

**Example:**

- Increase capacity from 1 → 2 instances
- Reduce capacity from 3 → 1 instance

Useful for simple workloads or testing.

---

# 2. Dynamic Scaling

Automatically responds to real-time changes in demand.

There are two major types: **Simple/Step Scaling** and **Target Tracking Scaling**.

---

## 2.1 Simple Scaling / Step Scaling

Triggered when a **CloudWatch alarm** fires.

You define:

- The condition
- How much to scale out or scale in

### Example:

- If average CPU > **70% for 5 minutes** → **add 2 instances**
- If average CPU < **30% for 10 minutes** → **remove 1 instance**

Simple = single adjustment

Step = multiple adjustments depending on the severity of the alarm

---

## 2.2 Target Tracking Scaling

The easiest and most commonly recommended strategy.

You define a **target metric**, and ASG automatically adjusts capacity to stay near that metric.

### Example:

- Maintain average CPU at **40%**
- Maintain average ALB RequestCountPerTarget at a specific threshold

ASG continuously scales to maintain that target.

Equivalent to **thermostat-style** auto scaling.

---

# 3. Scheduled Scaling

Scaling actions occur at **known, predictable times**.

Used when you know traffic patterns in advance.

### Example:

- “Every Friday at 5 PM, set minimum capacity to 10 because traffic spikes before the game.”

Perfect for:

- Business hours
- Batch processing
- Seasonal or event-driven patterns

---

# 4. Predictive Scaling (Machine Learning–based)

Predictive Scaling analyzes **historical patterns** and uses **machine learning** to forecast upcoming demand.

ASG then **pre-scales** your fleet before the load arrives.

### Benefits:

- Ensures capacity is ready before expected spikes
- Works best with repeating, time-based patterns
- Reduces the risk of resource shortages during sudden demand

### Example:

If the system learns that traffic always peaks from 1 PM–4 PM daily:

- ASG will automatically scale out **before** 1 PM
- Scale in after peak hours

This strategy appears in the exam.

---

# ⭐ Comparison Table

| Strategy | Trigger Type | Automation Level | Best For |
| --- | --- | --- | --- |
| **Manual Scaling** | None (manual) | Low | Simple workloads, testing |
| **Simple/Step Scaling** | CloudWatch alarms | Medium | CPU-based or threshold-based rules |
| **Target Tracking** | Maintain target metric | High | Web apps, steady load control |
| **Scheduled Scaling** | Time-based events | High | Predictable, known patterns |
| **Predictive Scaling** | ML-based forecasting | Highest | Repeating patterns, large workloads |

---

# 📌 One-Sentence Summary

> ASG strategies range from manual adjustments to ML-powered predictive scaling, allowing EC2 capacity to match demand through alarms, schedules, target metrics, or traffic forecasts.