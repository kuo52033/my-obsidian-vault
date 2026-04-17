---
notion-id: a596f80e-897f-4c66-9f57-0b092ee1b95e
---
> [!tip] 💡
> Scalibility is the property of a system to handle a growing amount of load by adding resources to the system

- more users, features, data, system complexity, geographies

### How to scale a system

1. Vertical Scaling ( scale up / down): more RAMs、fast CPU、additional storage，has limitations 
2. Horizontal Scaling ( scale out / in): adding more machine to system to spread the workload across multiple server，is the most effective way to scale for large system
3. Load Balancing: is a process of distributing traffic across multiple servers to ensure no single server become overwhelmed. (round robin)
4. Caching: store frequently accessed data in memory (like RAM) to reduce load on DB and improve response time
5. Content Delivery Networks (CDN): distribute static assets (image, video) colser to user，reduce lantecy and fater load time
![[螢幕擷取畫面_2024-06-06_202004.png]]
6. Partitioning: split data or functionality across multiple server to distribute workload and avoid bottlenecks，like AWS DynamoDB use partitioning for NoSQL
7. Asynchronous Communication: defer long-running or non critical tasks to queue or message broker. ensure main application remains responsive to users
8. Mircroservices Architecture: break down application into smaller, independent services that can be scaled independently. to handle different function.
9. Auto Scaling: Automatically adjust the number of active servers based on the current load，ensures the system can handle spikes in traffic without manual intervention
10. Multi-region Deployment: Deploy the application in multiple data centers to ensure service remain highly available and responsive to user all over the world
