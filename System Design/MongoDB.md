MongoDB is a **NoSQL ==document== database**. Data is stored as **JSON documents** instead of table rows.
```js
{
  _id: ObjectId("..."),
  roomId: "room_123",
  from: "user_a",
  text: "What is your return policy?",
  createdAt: ISODate("2024-01-01T00:00:00Z"),
  metadata: {
    read: false,
    tags: ["return", "support"]
  }
}
```

---

### Core Features
1. Schema-less
	No need to define fields upfront. Each document in the same collection can have a different structure
```js
// Both can exist in the same collection
{ _id: 1, text: "hello" }
{ _id: 2, text: "hi", image: "url...", reactions: ["👍"] }
```
✅ No migrations needed when requirements change, just add fields. 
❌ Data consistency has to be enforced at the application layer.

使用像 Mongoose 的 library 建立 schema，只是在應用層裡定義，MongoDB 不知道它的存在，因此用 shell 直接寫入不符合 schema 的資料，是擋不住的。 但像 Sequelize 這類的 SQL ORM 是會動到資料庫層的 ( await sequelize.sync() )

2. Embedded Documents
Related data can be nested directly inside a document, no JOIN needed
```js
{ 
	_id: ObjectId("..."), 
	text: "hello", 
	reactions: [ 
		{ userId: "user_1", emoji: "👍" }, 
		{ userId: "user_2", emoji: "❤️" } 
	] 
}
```

✅ One query gets everything you need. 
❌ Documents can get large if embedded data grows, which hurts performance.

較適合不常改的 document

3. Horizontal Scaling (Sharding)
MongoDB natively supports distributing data across multiple machines: 
```bash
Collection: messages 
├── Shard 1 ── roomId: A-M （Primary Shard）
├── Shard 2 ── roomId: N-Z 
└── Shard 3 ── overflow
```
✅ Scale out by adding machines, not upgrading to a bigger one.

4. Replica Set
Data is automatically synced across multiple nodes 
```bash
Primary ── async write ──> Secondary 1 
		──────────> Secondary 2
		
Primary goes down → Secondary auto-elected as new Primary
```
✅ High availability with automatic failover.

> [!NOTE] Eventual Consistency

預設行為是採用 CAP 中的 AP，但可以調整行為，用 Write Concern 和 Read Concern

---

### Trade-offs

✅ Good fit for MongoDB
- Data structure is flexible or changes frequently 
- Data is naturally nested (messages, comments, notifications) 
- Rapid development, no migrations 
- ==Read-heavy== workloads with simple query patterns

❌ Bad fit for MongoDB
- Complex multi-table JOINs
- Strong consistency requirements (e.g. financial transactions) 
- Highly relational data with many foreign keys 
- Full ACID guarantees needed

> [!NOTE] Transaction Limitations
> - Single document operations are atomic 
> - Cross-document, cross-collection transactions supported since v4.0, use Session, ==只能在 **Replica Set** 或 **Sharded Cluster** 上使用，standalone 不支援==
> - But performance is worse than SQL transactions → official recommendation is to avoid them
