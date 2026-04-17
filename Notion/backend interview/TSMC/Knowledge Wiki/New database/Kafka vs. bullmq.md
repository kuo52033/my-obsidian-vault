---
notion-id: 3385a6e2-1812-8037-87af-c663ab838b46
base: "[[New database.base]]"
多選: []
狀態: 進行中
---
- Kafka

```javascript
Topic：jobs
  ├── Partition 0：[Job1, Job4, Job7...]
  ├── Partition 1：[Job2, Job5, Job8...]
  └── Partition 2：[Job3, Job6, Job9...]
  

Partition 0 → Consumer 1 獨佔
              Job1 → Job2 → Job3（嚴格順序）
               
同一個 Group 的 Consumer 2 不能碰 Partition 0
→ 順序保證來自於「一個 Partition 只給一個 Consumer」
```

- BullMQ

```javascript
Queue：[Job1, Job2, Job3, Job4]

Consumer 1 拿 Job1
Consumer 2 拿 Job2  ← 同時
Consumer 3 拿 Job3  ← 同時

同一個 Group 的多個 Consumer 可以同時拿不同 Job
→ 保證每個 Job 只被拿一次，但完成順序不確定
```