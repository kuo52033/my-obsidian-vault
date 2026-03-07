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

3. Horizontal Scaling (Sharding)
MongoDB natively supports distributing data across multiple machines: 
```bash
Collection: messages 
├── Shard 1 ── roomId: A-M 
├── Shard 2 ── roomId: N-Z 
└── Shard 3 ── overflow
```
✅ Scale out by adding machines, not upgrading to a bigger one.