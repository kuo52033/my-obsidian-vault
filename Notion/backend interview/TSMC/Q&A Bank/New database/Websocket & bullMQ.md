---
notion-id: 3385a6e2-1812-80d6-9191-d319358f489d
base: "[[New database.base]]"
指派: []
狀態: 完成
---
我們有一個客服通訊系統，需要支援客戶與用戶之間的即時溝通、在線統計、AI 自動回覆和 RAG hybrid search。
如果把所有邏輯都放在 API request 裡同步執行，用戶要等 AI 處理、統計更新、通知廣播全部跑完才收到回應，latency 會非常高。
所以我們把不需要在 request 裡完成的任務拆出來，例如 AI 相關處理、通知廣播、即時統計，透過 BullMQ（Redis Stream）丟給獨立的 worker 非同步執行，API 把任務丟進 queue 後就馬上回應，latency 大幅降低。
另一個用到 Redis 的地方是 WebSocket 的訊息同步。多個 server 同時跑的時候，WebSocket 連線分散在不同 server 上，server 彼此不知道對方有哪些連線，沒辦法直接轉發訊息。
所以用 Redis pub/sub 作為廣播層，當有訊息要推送時，publish 到 Redis channel，所有 subscribe 這個 channel 的 server 都會收到，再各自轉發給自己這邊的連線者。
這樣 API server、worker、WebSocket server 三者完全解耦，每一層都是無狀態的，可以獨立水平擴展，任務量增加就加 worker，連線數增加就加 WebSocket server，不需要互相影響。

- **如果 redis 掛掉會有甚麼行為?**
    - Redis 掛掉對兩條線的影響不一樣。BullMQ 這條線影響最大，任務沒辦法丟進 queue。我們的做法是 Redis 本身用 ElastiCache 並開啟自動 failover，短暫不穩定時 BullMQ client 會重試連線。如果真的連不上，API 這端有 fallback，部分任務會降級成同步處理，確保核心功能不中斷。pub/sub 這條線，Redis 掛掉的話 WebSocket server 之間的廣播會中斷，用戶暫時收不到即時更新。但訊息本身已經存進 DB 了，不會遺失，client 重連後可以從 DB 補拉歷史訊息，所以影響是暫時的。根本的解法還是 Redis HA，讓 Redis 本身不容易掛，failover 時間夠短，對應用層的影響就能降到最低。
- 為什麼選擇 redis
    - 選擇 BullMQ 和 Redis pub/sub 主要有兩個考量。第一是我們已經有 Redis 了，用 BullMQ 和 pub/sub 不需要引入新的 infrastructure，維運成本最低。第二是功能對我們的場景夠用。任務佇列方面，BullMQ 提供的 retry、delay job、dead letter queue 已經滿足需求，不需要 Kafka 那種等級的吞吐量，引入 Kafka 反而是 overkill，架構複雜度會大幅上升。pub/sub 這塊，WebSocket 廣播的需求很單純，只需要把訊息廣播給所有 server，fire and forget 可以接受，因為訊息本身已經持久化在 DB，不依賴 pub/sub 保證送達。當然這個選擇也有取捨，如果未來任務量大幅成長，或需要更嚴格的訊息保證，可能需要評估遷移到 SQS 或 Kafka，但以當時的規模來說 Redis 是最合理的選擇。