
### Situation

系統有一個即時客服通訊功能，讓使用者和客戶之間互相溝通。原本的架構是：使用者發訊息 → HTTP Request → API handler 同步處理訊息儲存、業務邏輯 → 在同一個 request 最後透過 Socket 推播通知給對方。

隨著用戶量成長，兩個問題浮現：

1. **API response time（P50）持續攀升**：因為所有邏輯（儲存 DB、推播通知）都在同一個 request 中同步完成，任何一環變慢都拉高整體延遲
2. **新增 AI 客服功能**：引入了 RAG hybrid search（MongoDB）做智慧回覆，這是一個本質上就很耗時的操作，如果繼續放在同步流程中，API latency 會更加惡化

### Task

重新設計通訊架構，將同步流程拆解為即時通訊 + 非同步任務處理，使系統能水平擴展且保持低延遲。

### Action

**1. 通訊層改造 — HTTP → WebSocket**

- 將使用者與客戶之間的即時通訊從 HTTP polling 改為 WebSocket 長連線
- 訊息收發走 WebSocket，API 只負責低延遲的即時傳輸，不再承擔重型處理邏輯

**2. 非同步任務層 — BullMQ Worker**

- 將以下操作從同步流程中抽離，丟進 BullMQ 佇列由獨立 Worker 非同步處理：
    - **訊息持久化**：將聊天紀錄寫入 DB
    - **AI 客服回覆**：RAG hybrid search（MongoDB vector search + keyword search）產出回覆
    - **其他背景任務**：通知推播、訊息統計等
- Worker 以獨立 Pod 部署，可依負載獨立擴縮，不影響 WebSocket server

**3. 多 Pod 訊息同步 — Redis Pub/Sub**

- 問題：WebSocket server 跑多個 replica 時，User A 連到 Pod A、User B 連到 Pod B，彼此的訊息無法直接送達
- 解法：透過 Redis Pub/Sub 作為跨 Pod 的訊息廣播層，任何一個 Pod 收到訊息後 publish 到 Redis channel，所有訂閱該 channel 的 Pod 都會收到並轉發給各自連線的使用者
- 這讓 WebSocket server 可以無狀態地水平擴展，新增 Pod 只要訂閱相同 channel 即可

**4. 架構分層總覽**

```
Client ←→ WebSocket Server (多 Pod)
               ↕ Redis Pub/Sub（跨 Pod 訊息同步）
               ↓ 
          BullMQ Queue (Redis-backed)
               ↓
          Worker Pod（DB 寫入、AI RAG Search、推播通知）
```

### Result

- **API 延遲顯著下降**：原本同步處理的 request 改為 WebSocket 即時傳輸 + 非同步處理，使用者感受到的訊息傳遞幾乎是即時的，不再受 DB 寫入或 AI 搜尋的影響
- **系統可水平擴展**：WebSocket server 和 BullMQ worker 分別獨立部署、獨立擴縮，高峰期可以只加 worker 不動 WebSocket server，資源利用更精準
- **AI 客服功能順利上線**：RAG hybrid search 這類耗時操作放在非同步 worker 中，不阻塞即時通訊流程
- **架構解耦提升穩定性**：即使 worker 暫時掛掉，訊息仍會留在 BullMQ 佇列中等待重試，不會丟失；使用者的即時通訊體驗不受影響