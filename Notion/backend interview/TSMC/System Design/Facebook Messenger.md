---
notion-id: 30b5a6e2-1812-8097-b222-db7da00f4c51
---
1. 釐清需求
    1. functional requirements
        1. 支援一對一對話
        2. 須可以觀測使用者 online/offline
        3. 可以查看對話紀錄，需永久保存
    2. nonfunctional requirements
        4. minimum latency，使用者即時對話體驗
        5. highly consistent，使用者看到的對話紀錄在每個裝置需相同
        6. high availability，但可以稍微容忍一些來維持 consistent
2. 估算系統規模
    3. DAU: 500 M
    4. 每人每日發送訊息: 40 則，一則訊息 100 bytes
    5. 訊息 20 B/day，容量 2TB/day
    6. 20 B / 100000 秒 = 20 萬 QPS，巔峰時刻為2~5倍
    7. 假設 DAU 10% 會同時打開 APP，500萬並發連線
    8. 每個連線約10kb~100kb，因此需要 5TB RAM 伺服器(大約數百台機器)
3. High Level Design
    9. API Server
        7. 處理不需要即時的請求，如: 登入、修改使用者資訊、抓取歷史資訊等等，走  HTTP 請求
    10. Chat Server
        8. 用來維持 websocket 長連線的 stateful 機器，用來傳遞訊息
    11. Session/Presence Cache
        9. 記錄著全域的連線對應表，Ex: UserA → Chat_server_001、UserB → Chat_server_002
    12. Push Notification Server
        10. 當對方不在線上 (無 websocket)，透過底層通道把通知推到對方的裝置上
4. Detailed Component Design
    13. Messages Handling
        11. Pull(主動拉取): client 定期向 sever 詢問是否有新訊息
            1. 缺點: 大部分時間會取得空回應，浪費網路頻寬與伺服器資源，無法低延遲
        12. Push(伺服器推廣): client 跟 server 維持一個長連線， server 主動推波給用戶新訊息，實作技術用 HTTP Polling 或 WebSockets
        13. 重試機制 (解決網路不穩定)
            2. 接收端斷線: 如果遇到接收者剛好斷線( long polling or websockets timeout)，把訊息放在暫存區(MQ/buffer)，如果接收這重新連上，伺服器立刻把暫存訊息推給對方，確保訊息不遺失。( 若離線過久，則轉為 APNs/FCM 系統推播通知)
            3. 如果是傳送者剛好斷線，傳送者每隔幾秒重傳，直到重新連上網並收到 Server 的成功回報 (ACK) 為止，避免使用者手動重打字
        14. Concurrent Message
            4. 痛點: 依賴伺服器絕對時間 (Server Timestamp) 的災難
                1. 由於網路延遲，A與B同時發訊息時，若強制依賴伺服器收到的絕對時間來排序，會導致前端畫面上已顯示的訊息發生跳動，嚴重破壞 UX
            5. 例如
                2. 我發送訊息 M1，畫面上立刻顯示
                3. 伺服器收到 M1，時間為T1
                4. 對方同時發送訊息M2，他的畫面立即顯示M2
                5. 伺服器收到 M2，時間為T2，T2>T1
                6. 伺服器發訊息，M2→我、M1→對方
                7. 我的畫面 M1 → M2 (正常)
                8. 對方的畫面，如果按照伺服器時間排序，會發生跳動 M1 跑到 M2 上
            6. 解決：獨立遞增序號 (Local Sequence Number)
                9. 為每一位User 維護獨立的 Sequence Number，不強求每位使用者看到的順序會是一樣的
                10. 系統給我的對話框一個遞增序號: M1 (Seq: 100) → M2 (Seq:101)
                11. 給對方 M2 (Seq: 50) → M1 (Seq:51)
                12. 雖然雙方看到的訊息順序不一樣，但不影響聊天語意(因為視同時發出)，透過 Sequence Id，同一位使用者，系統保證所有裝置拉下來的順序，絕對會一模一樣。
    14. Storage
        15.  資料特性
            7. **極高併發寫入**：每天數百億條訊息不斷新增，且幾乎不會修改或刪除。
            8. **循序讀取 (Sequential Read)**：使用者通常只會看「最近的幾十條訊息」，很少會去翻幾年前的舊帳。
            9. **範圍查詢 (Range Query)**：讀取時不是拿單一 ID 找單一訊息，而是一次撈取某個時間段的「一整批訊息」。
        16. 首先排除 SQL，因為會有寫入瓶頸與分片地獄， Document NoSQL (MongoDB)，也會有不必要的效能與儲存開銷
        17. Key-value DB 確實存取及快，但很難做到範圍查詢，因此需要使用他的進階版: **Wide-Column Store NoSQL (寬列資料庫，如 Apache Cassandra 或 HBase)**。
            10. 寫入速度突破天際
                13. 傳統用 B+ Tree 架構，每次寫入時要在硬碟裡找空位並重新平衡樹狀結構，非常耗時(random I/O)，在百萬QPS會直接癱瘓
                14. Wide-Column DB 是使用 **LSM-Tree (Log-Structured Merge-Tree)**。會先把幾萬筆訊息先暫存在記憶體裡，等記憶體滿了，再一次性、連續地寫入到硬碟中 (Sequential I/O)
                15. Partition Key + Clustering Key (分片鍵與排序鍵)，我們可以用 `Thread_ID` (聊天室 ID) 當作 Partition Key，讓同一個聊天室的訊息都落在同一台機器上；再用 `Sequence_ID` (訊息序號) 當作 Clustering Key，讓硬碟裡的資料按時間順序排好。當你要「往上滑看歷史紀錄」時，資料庫只要做一次 Range Scan 就能瞬間吐出 50 條訊息。
                16. Schema-free / Sparse Data Friendly (無固定綱要與稀疏資料友善)，使用者的訊息長度差異極大，有人只傳一個「嗯」(2 Bytes)，有人傳了一整篇長文 (2000 Bytes)。在傳統關聯式資料庫中，如果欄位長度不一或是有很多空值 (Null)，可能會浪費許多儲存空間。而 Wide-Column DB 每一個 Row 的 Column 數量跟長度都可以動態變化，不會浪費任何 1 Byte 的硬碟空間
                17. 內建 Consistent Hashing，加入新機器後，會自動在背景搬移資料、平衡負載
    15. Managing user’s status
        18. 在線狀態是一種高頻率、短暫性的資料。系統設計的核心目標是：極大化降低資料庫寫入壓力，並絕對避免廣播風暴 。
        19. ❌ 錯誤設計：每次上/下線都寫入資料庫 。這會導致資料庫被超高 QPS 瞬間打掛
        20. ✅ 標準解法：純 In-Memory 儲存
            11. **Heartbeat (心跳)**：Client (手機) 只要保持在線上，每隔 30 秒就會透過 WebSocket 底層發送一個極小的 ping 封包給 Chat Server
            12. TTL (存活時間)：伺服器收到 Ping 後，會在 Redis 裡將該 User 的 Key 存活時間 (TTL) 延長至 60 秒
            13. 如果使用者斷線，60秒一到 redis 上的 key 會自動過期刪除，判定為離線
            14. 為了扛住 5 億 DAU 同時發送 Ping，Server **不會**每次收到 Ping 就去寫 Redis。它會在記憶體中批次收集，每隔 3 分鐘才把活著的名單打包，一次性對 Redis 執行批次更新，將負載降低數百倍。
        21. 獲取好友狀態
            15. ❌ 錯誤設計：一打開 App 就把所有 500 個好友的狀態全部拉下來，並隨時保持同步
            16. ✅ 標準解法：按需獲取 (Lazy Loading)，只有當使用者滑動好友列表，client 才會向使用者 pull 這畫面上20人的最新狀態
        22. 更新好友狀態
            17. ❌ 錯誤設計 (廣播風暴 / Fanout Problem)：當 User A 上線/離線時，伺服器主動 Push 通知給 A 的「所有 500 個好友」。
            18. ✅ 標準解法：Redis Pub/Sub (發布/訂閱機制) 達成的 Targeted Push (精準推播)，伺服器只會把上線/離線通知，推撥給目前正在線上，而且剛好打開著好友列表 / 正在跟 A 聊天的好友
            19. 針對**異常斷線（如網路中斷/設備斷電）**，Client 無法主動發送離線通知。此時需依賴 Redis 的 **Keyspace Notifications** 功能。當心跳 TTL 過期導致 Key 被自動刪除時，伺服器會監聽此過期事件，並主動向 Pub/Sub 頻道代發離線事件，確保訂閱者能正確更新為離線狀態。
    16. Media Upload Architecture
        23. 在即時通訊軟體中，處理圖片、影片等媒體檔案，若將檔案直接透過後端伺服器上傳，會引發效能問題
        24. 🚨 client → Server → S3
            20. 記憶體撐爆 (OOM, Out of Memory) 危機：若遭遇高併發（例如百人同時上傳 1GB 影片），伺服器記憶體會瞬間被二進制串流塞爆，導致伺服器崩潰，連帶拖死其他輕量級的 API (如文字對話、登入等)。
        25. 🏆 解法: S3 Presigned URL
            21. Server 不再負責接收檔案，而是發證機關，大檔案直接走S3
                18. 前端申請: client 告訴 Server 準備上傳檔案
                19. 核發通行證: Server 驗證使用者後，向 S3 「限時、限地」的臨時通行證，回傳 Presigned URL 給 client
                20. 前端直傳: 對著 URL PUT 請求，檔案的流量由 S3 頻寬扛下，不由我們的 Server 所接收
                21. 通知完成: 上傳完成後，Client 發送 API 通知任務完成，Server更新狀態
            22. 上傳規則可以寫在通行證中，例如限制大小 content-length-range、限制格式 Content-Type





















