MongoDB is a **NoSQL document database**. Data is stored as **JSON documents** instead of table rows.
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