

 - **你們的 CS 系統需要支援多個 Server instance 同時運行，當用戶 A 連到 Server 1，客服 B 連到 Server 2，客服 B 傳訊息給用戶 A，你們是怎麼解決這個問題的？**
	 - 我們用 Kubernetes 部屬，前台至少跑了 3 個 pod，每個 pod 裡有一個 server instance，這三個都會建立 websocket 連線，要解決這個跨 server 的通訊問題，必須有個廣播中介，我們使用的工具是 redis publish/subscribe，server 如果有先訂閱相關的 channel (ex: chat: room_123)，就會收到其他 sever publish 至 redis 的訊息，並用 websocket 傳遞給指定的 user，使用這個工具的優點是已經有 redis 部屬，並且簡單夠用，缺點是事件不會保留，沒有 ACK 確認訊息。訊息遺失的補救方式是同時把訊息寫進 mongoDB 持久化，斷線重連後用 http 從 db 補讀。
	 
- **你們的 CS 系統用 BullMQ 處理非同步任務，可以說說當一個 AI 回覆的 job 失敗了，你們怎麼處理？另外如果 Worker 在處理 job 的過程中突然 crash，會發生什麼事？**
	- 