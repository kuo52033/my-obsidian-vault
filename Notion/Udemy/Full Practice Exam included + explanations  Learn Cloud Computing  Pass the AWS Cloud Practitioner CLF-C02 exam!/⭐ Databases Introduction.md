---
notion-id: 2b55a6e2-1812-80b4-aff5-f53ee4a638df
---
## What Is a Database?

A database stores data in a **structured format**, allowing you to:

- Efficiently search and query information
- Build indexes
- Define relationships between data
- Scale storage and compute as your application grows

Compared to storing raw files on EBS, EFS, or S3, databases provide **schema**, **query languages**, and **optimized data access patterns**.

---

## Relational Databases (SQL)

Relational databases organize data into **tables** (similar to Excel sheets) with defined **relationships** between them.

### Example (Visual Table Representation)

**Students Table**

| student_id | department_id | name | email |
| --- | --- | --- | --- |
| 1 | 10 | Alice | alice@test.com |
| 2 | 20 | Bob | bob@test.com |

**Departments Table**

| department_id | department_name |
| --- | --- |
| 10 | Engineering |
| 20 | Marketing |

→ The `department_id` links the two tables (a “relation”).

### Characteristics

- Uses **SQL** (Structured Query Language)
- Enforces **schema** (strong structure)
- Great for transactional apps (e.g., banking, e-commerce)
- Vertical scaling is common (bigger instance = better performance)

---

## NoSQL Databases (Non-Relational)

NoSQL databases are designed for **flexibility**, **scalability**, and **high performance**.

### Benefits

- **Flexible schema** — easy to evolve data structure
- **Horizontal scalability** — add more servers easily
- **High performance** for specific data models
- **Optimized for modern apps** (mobile, IoT, analytics)

### Common NoSQL Models (Exam-Relevant)

| Type | Description | Example Use |
| --- | --- | --- |
| **Key–Value** | Simple key → value mapping | Caching, session storage |
| **Document** | JSON-like documents | User profiles, product catalogs |
| **Graph** | Nodes + relationships | Social networks, recommendations |
| **Search** | Full-text search engine | Log search, app search |
| **In-Memory** | Ultra-fast RAM storage | Real-time leaderboards, caching |

### Example JSON Document (Visual)

```json
{
  "name": "John",
  "age": 30,
  "cars": ["Ford", "BMW", "Fiat"],
  "address": {
    "street": "Main Rd",
    "city": "NY"
  }
}


```

Characteristics:

- Nested objects
- Arrays
- Fields can change over time
- Ideal for NoSQL systems like DynamoDB, DocumentDB, Elasticsearch, etc.

---

## Why Use Managed Databases on AWS?

AWS provides **managed database services**, meaning AWS handles:

### AWS Responsibilities

- High availability
- Automated backups
- Patching (OS + database engine)
- Monitoring & alerts
- Scaling capabilities
- Infrastructure maintenance

These reduce operational overhead and improve reliability.

---

## Running Your Own Database on EC2

If you self-manage databases on EC2, **you** must handle:

- Backup & restore
- High availability design
- OS/database patching
- Security hardening
- Failover & replication
- Scaling
- Monitoring

This is more work and less resilient compared to managed services.

---

## Exam Focus

For CLF-C02, you should understand:

- Relational vs NoSQL databases
- SQL vs non-SQL models
- Why managed databases are preferred
- Basic use cases for each database category
- Shared responsibility: AWS handles maintenance for managed DB services