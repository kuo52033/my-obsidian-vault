HTTP 的問題是：**每次溝通都是一次性的**。Client 發請求，Server 回應，連線就結束了。

如果你需要「Server 主動推送資料給 Client」（例如即時訊息、通知），HTTP 做不到，你只能一直輪詢（polling），很浪費。

WebSocket 解決這個問題：

> **一次握手，建立持久的雙向連線。之後 Client 和 Server 都可以隨時主動發訊息。**

### 連線過程

WebSocket 握手其實就是一個**特殊的 HTTP Request**。 Client 用 HTTP 敲門，說「我想升級成 WebSocket」，Server 同意後，這條 TCP 連線就不再走 HTTP 了。

-  Step 1 - Client 發送升級請求
```http
GET /chat HTTP/1.1
Host: server.example.com
Upgrade: websocket 
Connection: Upgrade
Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==
Sec-WebSocket-Version: 13
```

- Step 2 - Server 回應
```http
HTTP/1.1 101 Switching Protocols 
Upgrade: websocket 
Connection: Upgrade 
Sec-WebSocket-Accept: s3pPLMBiTxaQ9kYGzzhZRbK+xOo=
```

- Step 3 - TCP 連線被接管
	- 這條 TCP 連線繼續存在，不會關閉 
	- 但上面跑的不再是 HTTP，而是 **WebSocket Frame 格式** 
	- 雙方都可以隨時主動發訊息

-  Step 4 - Ping/Pong 保持連線存活
	TCP 連線如果長時間沒有資料傳輸，中間的防火牆或 Load Balancer 可能會把它砍掉。 所以 WebSocket 有內建的心跳機制

## Authentication

### 核心概念﹔在握手發生前攔截

```
Client 發 HTTP Upgrade 請求
        ↓
server.on('upgrade') 攔截  ← 你在這裡做驗證
        ↓
驗證通過 → wss.handleUpgrade() → 升級成 WebSocket
驗證失敗 → socket.destroy() → 連線直接斷掉
```

關鍵在於：**WebSocket 還沒建立，這時候還是 HTTP 請求**，所以你可以用所有 HTTP middleware 的工具來做驗證。

---

把多個驗證 middleware 串成一個函式
```
session -> passportInitialize -> passportSession -> validateUser

session: 從 HTTP Request 的 Cookie 裡讀取 session ID，去 session store（通常是 Redis）撈出對應的 session 資料，掛到 req.session 上。
passportInitialize: 在 req 掛上 req.user
passportSession: 從 req.session 裡反序列化出 user 物件，掛到 req.user
validateUser: 判斷使用者的權限，是否合法
```

任何一層呼叫 `next(error)` 就會跳到最後的 error handler

--- 

驗證全部通過後，才真正把這條 TCP 連線升級成 WebSocket，然後 emit `connection` 事件，進入正常的 WebSocket 處理流程。
```js
wss.handleUpgrade(req, socket, head, ws => { wss.emit('connection', ws, req) // req 傳進去是因為你之後可能需要 req.user })
```

## 整體流程
```
Client 發 Upgrade 請求（帶 Cookie） 
    ↓ 
session() 從 Cookie 撈出 session 
    ↓ 
passport 從 session 還原 req.user 
    ↓ 
validateUserStatus 確認帳號狀態 
    ↓ 
┌───┴──────────────────────────────┐ 
失敗                              通過 
 ↓                                 ↓ 
socket.destroy()        handleUpgrade() 
                                   ↓ 
                       connection 建立 req.user 可用
```