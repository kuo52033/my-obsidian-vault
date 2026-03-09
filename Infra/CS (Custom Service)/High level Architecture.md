```mermaid 
flowchart TD 
	Client -->|WebSocket| Server 
	Server -->|Pub/Sub| Redis 
	Server -->|Add Job| BullMQ 
	BullMQ -->|Process| Worker 
	Worker -->|RAG Query| VectorDB 
	Worker -->|Generate| OpenAI 
	Worker -->|Publish Result| Redis 
	Redis -->|Push| Server 
	Server -->|Persist| MongoDB
```
