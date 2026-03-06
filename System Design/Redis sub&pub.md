### 為什麼需要

先想一個問題：

> 有多個 Server instance 在跑（水平擴展）。
> 
> 用戶 A 連到 **Server 1**，用戶 B 連到 **Server 2**。  B 傳訊息給用戶 A，**Server 2 怎麼通知 Server 1？**

每個 Server 只管理自己的 WebSocket 連線，它不知道其他 Server 上有誰。

```
用戶 A  ──── ws ────  Server 1
客服 B  ──── ws ────  Server 2

Server 2 想傳訊息給用戶 A，但用戶 A 不在 Server 2 上
```

這就是 Redis Pub/Sub 解決的問題。

---

### Pub/Sub 的概念

| 角色         | 說明                  |
| ---------- | ------------------- |
| Publisher  | 發布訊息到某個 channel     |
| Subscriber | 訂閱某個 channel，有訊息就收到 |
| Channel    | 訊息的頻道，是一個字串名稱       |
```
Publisher  ── publish('chat:room1', msg) ──>  Redis
                                                ↓
Subscriber 1  <── 收到 msg ──────────────────  Redis
Subscriber 2  <── 收到 msg ──────────────────  Redis
```
**所有訂閱同一個 channel 的人都會收到訊息**，Redis 負責廣播。

### 重要特性 (Trade-off)

- 沒有確認機制（No Acknowledgement）
	- HTTP 有 response，你知道對方收到了。 Pub/Sub 沒有，publish 之後你不知道有沒有人真的收到。
	- 解法: 訊息寫入資料庫，收到後標記為已讀，就知道有沒有收到
- 沒有順序保證 (跨 channel)
	- 同一個 channel 內的訊息是有順序的。 但如果你用多個 channel，不同 channel 之間的順序沒有保證。

> [!TIP]  訊息發出去的當下，沒有訂閱者在線，訊息就消失了。Redis 不會儲存它。





