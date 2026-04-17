---
notion-id: f93d3aa4-8078-47f1-b388-50d6ea904a4b
---
Data partitioning is a method used in database design and optimization to divide a very large database into smaller, more manageable parts. There are three main types of data partitioning:

1. **Horizontal partitioning**: This involves dividing a database into two or more tables, each containing the same number of columns but fewer rows. Each table then holds different rows of data but the same kind of data.
2. **Vertical partitioning**: This involves dividing a database into two or more tables that contain fewer columns and the same number of rows. Each table then holds different columns of data and the same rows.
3. **Functional partitioning**: This involves dividing a database based on the functions performed by different sections of an organization. Each function or department in the organization would have its own database.

Partitioning can significantly improve the performance of a database. It reduces the amount of data that needs to be loaded into memory and allows queries to be distributed across multiple servers, thus reducing the load on any single server.