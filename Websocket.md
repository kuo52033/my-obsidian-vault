HTTP 的問題是：**每次溝通都是一次性的**。Client 發請求，Server 回應，連線就結束了。

如果你需要「Server 主動推送資料給 Client」（例如即時訊息、通知），HTTP 做不到，你只能一直輪詢（polling），很浪費。

WebSocket 解決這個問題：

> **一次握手，建立持久的雙向連線。之後 Client 和 Server 都可以隨時主動發訊息。**

### 連線過程
