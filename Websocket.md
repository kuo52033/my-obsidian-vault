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