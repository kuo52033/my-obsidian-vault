

```
用戶 A  ──── ws ────  Server 1
客服 B  ──── ws ────  Server 2

Server 2 想傳訊息給用戶 A，但用戶 A 不在 Server 2 上

Redis Pub/Sub 需要解決的問題。
```

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

### 跟 [[Redis Stream & Redis List]]的差異

> [!INFO] 為什麼用 Pub/Sub
> - 即時性優先
> - 不需要 Stream 的複雜度，延遲較低
> - 不在乎丟失
> 

---

### Channel Mapping

實際上存的是 **client 的 socket connection 參考**
```json
{
  "news":   [conn_fd_5, conn_fd_12, conn_fd_38],
  "sports": [conn_fd_12, conn_fd_27],
}
```
`conn_fd` 是 file descriptor，也就是 TCP 連線的 socket handle，Redis 透過這個直接寫資料給 client。

### 運作流程

**Step 1 : client 訂閱**

```c
//Client A 發送：SUBSCRIBE news

// 把這個 client 的 fd 加進 news 的訂閱列表
subscriptions["news"].add(client_A.fd)

// 同時在 client 身上也記一份，它訂了哪些 channel
client_A.subscribed_channels.add("news")
```

兩邊都記，是為了方便反向查找（client 斷線時快速清掉它的所有訂閱）。

**Step 2：Publisher 發布**

```c
// Client B 發送：PUBLISH news "hello"

// 查訂閱表 
subscribers = subscriptions["news"]  

// 對每個 fd 直接寫 socket 
for each fd in subscribers: 
	write(fd, "hello")
```

**Step3 : client 斷線**

```c
// 從 client 身上拿到它訂閱的所有 
channel channels = client_A.subscribed_channels // ["news", "sports"] 

// 從每個 channel 的列表中移除這個 fd 
for each channel in channels:
	  subscriptions[channel].remove(client_A.fd)
```