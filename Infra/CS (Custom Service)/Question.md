

 - 你們的 CS 系統需要支援多個 Server instance 同時運行，當用戶 A 連到 Server 1，客服 B 連到 Server 2，客服 B 傳訊息給用戶 A，你們是怎麼解決這個問題的？
	 - 我們用 Kubernetes 部屬，前台至少跑了 3 個 pod，每個 pod 裡有一個 server instance，這三個都會建立 websocket 連線，要解決這個跨 server 的通訊問題，必須有個廣播中介，我們使用的工具是 redis publish/subscribe，