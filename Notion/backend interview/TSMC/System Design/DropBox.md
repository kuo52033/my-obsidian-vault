---
notion-id: 3095a6e2-1812-80ba-a79e-c91dbc8fd854
---
1. 釐清需求
    1. functional requirements
        1. 使用者可以上傳檔案，並在所有設備上自動同步
        2. 支援大檔案，可以到GB
        3. 支援離線，使用者在沒有網路時能修改檔案，連上網後自動同步
        4. ACID，對資料一致性的要求
    2. nonfunctional requirements
        5. Availability，使用者在任何時間、地點都可以存取檔案
        6. Reliability，使用者上傳的資料絕不能遺失
        7. Scalability，使用者絕不需擔心上傳的檔案導致空間不足，必須提供足夠的空間
        8. 大量的讀寫，比例1:1
2. 估算系統規模
    3. 500M使用者，100 DAU
    4. 每位使用者平均有三種不同的裝置
    5. 每位使用者有 200 files/photos，總共約 100 B個檔案
    6. 平均每個檔案約 100KB，總用約 10PB
    7. 假設每分鐘約有1M個連線
3. High Level Design
    8. client (客戶端/本機工作區)
        9. 持續觀察使用者在電腦上指定的資料夾，只要有任何CUD，就會啟動準備處理檔案
    9. Block Servers (區塊伺服器)
        10. 負責接收 client 傳遞過來的「實體檔案區塊 (chunks)」，或是下載給 client，背後連接的是 cloud object storage
    10. Metadata servers (元數據伺服器)
        11. 不碰檔案，只負責記錄「檔案名稱、大小、資料夾路徑、檔案被切成了哪些 Hash 區塊、以及誰有權限看 」
        12. 背後連接 SQL 或 NOSQL，當把檔案更名，或把檔案移到其他資料夾，client通知 metadata server，改資料庫裡的資料，不須透過 block server
    11. Synchronization Servers (同步伺服器)
        13. 負責處理多設備同步的流程，在手機刪除一張照片，metadata server 更新完資料庫後，需要notify所有客戶端，告訴電腦、平板，檔案改變了需要同步
4. Component Design
    12. Clients
        14. Watcher
            1. 觀測電腦裡的 dropbox 資料夾，一按 ctrl+s 存檔，立即抓到作業系統底層API (例如 window ReadDirectoryChangesW or Mac FSEvents ，並傳遞修改事件給 Indexer
            2. 透過 Long Polling 監聽 Synchronization Server，看雲端有沒有更新指令傳過來
        15. Indexer 
            3. 負責接收 watcher 的事件，並決定要更新本機資料庫、通知 chunk 開始切塊、跟 Synchronization 通知要更新所有客戶端、更新 metadata 資料庫
        16. Chunker
            4. 上傳: 負責把大檔案切成 4MB 的 chunk，計算那些塊被修改，並上傳至雲端
            5. 下載: 負責把雲端抓下來的 chunk，拼湊成一個完整的檔案
        17. Internal Metadata DB
            6. 記錄所有檔案的路徑、Chunk 的 Hash 值、版本號碼等
        18. 流程(正常狀態): 修改了 C:\Dropbox\履歷.docx → watcher 觀測到，把修改事件傳給 indexer → 呼叫 chunker 檢查履歷，檢查每一個 chunk 的 hash是否有變動 (根據 internal DB) → 把有變動的上傳至 block server → 回報 indexer 修改成功 → 更新 internal DB version 及變更的 chunk → 通知 Synchronization Servers 廣播其他使用者的裝置告訴說，新的 metadata 已更新
        19. 流程2(沒有網路): 流程差別在於 chunker 不會嘗試跟 block server 連線，而是先回報 indexer → indexer 把新資料更新至 db 後更改狀態成 PENDING_UPLOAD → indexer 檢查到有網路後去查 internal DB PENDING 的資料 → 通知 chunker 上傳至 block server → indexer 再通知 通知 Synchronization Servers → PENDING_UPLOAD 狀態清空
    13. Metadata Database
        20. 需要ACID 特性，保證資料庫交易安全的機制，因為如果刪除紀錄及新增紀錄中途失敗，對 dropbox 是災難性存在，必須保證檔案的絕對一致性。
            7. 方案A: SQL
                1. 優點: 天生內建 ACID
                2. 缺點:難以橫向擴展 scale-out，必須手動 sharding
            8. 方案B: NoSQL
                3. 優點: 天生為擴展而生，再多檔案都塞的下
                4. 缺點: 傳統NoSQL 為了效能，放棄了跨表 ACID，必須在應用曾自己手刻 Two-Phase Commit，容易出bug
    14.  Synchronization Service
        21. 功用
            9. 接收 Client 傳來的檔案變更請求
            10. 將 Client 的 internal DB 與雲端的 Remote Metadata DB 進行一致性比對與更新
            11. 一旦確認檔案有更新，立刻透過長輪詢 (Long Polling) 等機制，向所有訂閱該檔案的裝置 (Devices) 推播更新通知
            12. 當斷網的 Client 重新連線時，Sync Service 會處理其積壓的更新請求並回傳最新的檔案狀態。
        22. 傳輸優化
            13. 不傳輸完整的檔案！系統統一將檔案切割為 **4MB 的小區塊 (Chunks)**
            14. Client 與 Server 透過比對區塊的 SHA-256 雜湊值，精準找出「被修改的區塊」
            15. 當 Server 發現 Client 準備上傳的 Chunk Hash 已經存在於庫中（即使是其他不認識的用戶上傳的），Server 會直接拒絕實體檔案傳輸，僅更新 Metadata DB 的指標，達成「秒傳」並極大化節省 S3 儲存空間。
        23. 一致性檢查與衝突處理
            16. 當發生並行修改-例如你在高鐵上斷網修改了 V1，同時你老闆在辦公室把雲端的 V1 改成了 V2，當你連上網準備上傳時就會引發衝突。
                5. ❌ 錯誤解法：最後寫入者贏，如果系統直接讓你的檔案覆蓋老闆的檔案，會導致資料遺失
                6. ✅ 標準解法：Conflicting Copy (產生衝突副本)。Sync Service 會保留雲端上老闆的 V2 檔案 (原檔名)，並將你的檔案重新命名為 `檔名 (你的名字 conflicted copy).副檔名`，然後將兩個檔案同時廣播給所有使用者。系統不主動刪除任何人的心血，而是將「合併 (Merge) 的責任」交還給使用者手動處理。
    15. Message Queue
        24. client 與 synchronization service 絕不能使用同步 API 呼叫，引入非同步的通訊中介軟體 Messaging middleware
            17. client → server，多對一 queue，為了讓後端遇到多大的突發流量，都能照自身能力平穩拉取任務
            18. server → client，一對一 queue，因為傳統 queue 是閱後即焚，共用 queue 的話會導致只有一個裝置收到通知，因此必須將通知複製到各個裝置的專屬 queue 中
            19. 在全球 5 億台裝置的規模下，若真的「每個裝置開一個 Queue」，伺服器的記憶體與連線數會瞬間被撐爆
                7. 引入 log-based broker (如 kafka)
                    1. 為每個用戶建一個 Topic
                    2. 資料寫入 kafka後不會消失，而是保留一段時間
                    3. client 端會記錄上次的版本，斷網重連時，再主動 call HTTP 請求，解決漏接問題
                8. 引入傳輸層 notification service
                    4. 作為 consumer，pull 出事件，查詢  metadata DB 確認有檔案權限的裝置
                    5. 查詢全域連線字典 (redis)，伺服器利用  websocket 通送訊息，即時更新
                    6. 上億等級連線數，單點 Redis 絕對承受不住，建立 Redis Cluster，並以 UserId 作為 sharding key  進行分片，流量均勻分散，搭配 heartbeat 機制，由server自動清除異常斷線的 device
5. data deduplication
    16. 為了節省雲端儲存成本與網路頻寬，系統透過計算每個區塊 4MB的 hash值，並跟資料庫做比對，來確保世界上完全相同的資料區塊，在硬碟裡只會有一份
        25. 方案 A (post-process deduplication): client 甚麼都不管，伺服器先全部照單全收、存進硬碟，再啟動一個背景程式 (Background Job) 去掃描硬碟，找出 Hash 一樣的重複區塊並刪除，最後修改 Metadata 的指標。
            20. 優點:  client 不需要等待確認 hash 的時間
            21. 缺點: 浪費頻寬、浪費暫存空間
        26. 方案 B ( in-line deduplication): client 上船前，立即算出 chunk hash 並傳給伺服器詢問，如果伺服器發現這個 Hash 已經存在，系統就不會進行實體檔案傳輸，而是僅在 Metadata 中新增一筆「指標 (Reference)」指向現有區塊。
            22. 優點: 節省使用者的上傳頻寬、秒上傳
            23. 缺點: client 端需要消耗 CPU 來計算 hash，且上傳前須多一次與 metadata server 網路來回通訊的時間
6. database partitioning
    17. ❌ **Vertical Partitioning**
        27. 將不同功能的表放在不同伺服器(user 表放一台、file 表放另一台)
        28. 缺點: 無法解決單表容量無上限擴展的問題，跨伺服器join 有嚴重的延遲
    18. ❌ **Range-Based Partitioning **
        29. 依照檔案名稱或特徵切分（例如：A-M 開頭的放一台，N-Z 的放另一台）
        30. 缺點: 極易產生「資料傾斜 (Data Skew)」與「熱點 (Hotspots)」，導致某些伺服器被撐爆，某些卻閒置
    19. ✅ Hash-Based Partitioning
        31. 拿物件的唯一識別碼（如 `FileID` 或 `WorkspaceID`）計算 Hash 值，再將結果均勻分配到各個 Partition 伺服器中
        32. Consistent Hashing (一致性雜湊)：為了避免未來新增或減少伺服器時，引發全庫資料重新洗牌的「搬遷風暴 (Massive Rebalancing)」，必須搭配一致性雜湊環，讓擴容時只需搬移極小部分 (`1/N`) 的資料




