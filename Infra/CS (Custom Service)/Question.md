

 - **你們的 CS 系統需要支援多個 Server instance 同時運行，當用戶 A 連到 Server 1，客服 B 連到 Server 2，客服 B 傳訊息給用戶 A，你們是怎麼解決這個問題的？**
 
	 - 我們用 Kubernetes 部屬，前台至少跑了 3 個 pod，每個 pod 裡有一個 server instance，這三個都會建立 websocket 連線，要解決這個跨 server 的通訊問題，必須有個廣播中介，我們使用的工具是 redis publish/subscribe，server 如果有先訂閱相關的 channel (ex: chat: room_123)，就會收到其他 sever publish 至 redis 的訊息，並用 websocket 傳遞給指定的 user，使用這個工具的優點是已經有 redis 部屬，並且簡單夠用，缺點是事件不會保留，沒有 ACK 確認訊息。訊息遺失的補救方式是同時把訊息寫進 mongoDB 持久化，斷線重連後用 http 從 db 補讀。
 ---
 
- **你們的 CS 系統用 BullMQ 處理非同步任務，可以說說當一個 AI 回覆的 job 失敗了，你們怎麼處理？另外如果 Worker 在處理 job 的過程中突然 crash，會發生什麼事？**

	- 當 ai 回覆 job 失敗時，可能是過程中發生error導致中斷，我們有設置 retry strategy，並且設置 exponential backoff，重試的秒數以指數成長，並免短時間連續打 API，如果三次都失敗，將該job 標記為 failed，降級回傳一個錯誤訊息( ai response error) ，並且通知客服人員需要接手此對話。如果在處理過程中 worker 因為OOM 之類的問題導致整個崩潰，因為有心跳機制(可藉由 stalledInterval 調整秒數)，如果 bullMQ 判斷 job 為 stalled，會自動把 job 重新放回 wating queue，給其他 worker 重新處理，預防此事情發生可以平行運行多個 worker, auto scaling group 的策略。

---

 - **你們的 CS 系統使用 RAG 來讓 AI 回答用戶問題，可以解釋一下整個流程是怎麼運作的？從知識庫建立到用戶收到回覆，完整說一遍。**
 
	 - 直接串接現在的 AI ，有個問題是AI 不知道我們客戶的資訊，因此在回應上的成效不佳，因此在我們的客服系統加上 RAG ，也就是先把客戶相關的文件切成固定大小的 chunk，每個chunk 大約 500 tokens，之間有 overlap，再用 embedding model 把這些 chunk 轉換成一長串的數字，叫做 vector，並且把 vector 存進 vector database，我們是使用 mongodb。流程的話會是，用戶傳訊息給 client server，再來非同步 bullMQ 同時存進資料庫，回傳 201 告訴前端 job 已經傳送出去，介面顯示「AI 正在輸入中....」，worker 收到事件後，將用戶訊息embedding 後去 vector db 做語意搜尋，把循循到的資訊跟 user input 組成 prompt 餵給 openAI API，最後再發送  redis pub/sub 傳送至用戶。因為純向量搜尋對關鍵字和專有名詞效果差，所以我們加入 BM25 做關鍵字搜尋以及 synonyms 擴展詞彙範圍，將三種結果合併做 hybrid search，取最相關的 top k 給 AI。

---

- **如果今天 CS 系統的用戶量突然暴增，從原本的 1,000 個同時連線變成 10,000 個，你們的系統會在哪些地方出現瓶頸？你會怎麼處理？**
	- 就是 server 的記憶體會提高，因為連線 websocket 是有狀態的，嚴重會導致OOM 並且崩潰，輕微則是系統整體的 latency 突然飆高，前台卡頓影響用戶體驗，如果發生這種狀況，我首先會去架設好的 ELK 看 log，有出什麼錯誤訊息，以及 kibana 查看記憶體和 CPU 的數值，確認是連線暴增造成的後，我會先緊急擴充pod/server 的數量，至少先讓前台不會卡頓，之後要提高系統的可用性，我會先調整 server 的 auto scaling group 策略，加入記憶體的監測，如果超過 70% 就開新的 server，