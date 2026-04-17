---
notion-id: 3075a6e2-1812-8004-aff7-cdf0eb7e0473
---
1. 釐清需求
    1. 功能性需求
        1. 使用者可以上傳/下載/觀看圖片
        2. 使用者可以搜尋圖片藉由標題
        3. 使用者可以追隨其他使用者
        4. 系統需產生動態牆，根據每位追隨使用者的最新貼文
    2. 非功能性需求
        5. 高可靠性(reliability) ，用戶上傳的資料不能遺失
        6. 高可用性(availability)，系統隨時能讀取
        7. 低延遲(latency)，快速回傳動態牆 200ms
        8. 如果使用者發了照片，過了幾秒or幾分，他的粉絲才看到是ok的，eventual consistency 最終一致性
2. 估算系統規模
    3. 總用戶共 500M ，日活耀用戶 1M 
    4. 每天有 2M 張照片上傳
    5. 平均每張 200KB
    6. 2M x 200 KB = 400GB/day
    7. 10年儲存量: 400GB x 365 x 10 = 1460TB
3. db schema
| photo | user | userfollow |
| --- | --- | --- |
| id (pk) | id | flollowerUserId(粉絲) |
| path | name | followeeUserId (被追隨者) |
| photoLatitude | lastLogin |   |
| photoLongtitude | email |   |
| userLatitude | birth |   |
| userLongtitude |   |   |
| createAt |   |   |

    - 直觀上因為需要讓 photo 關聯至 user，以及 follow table，會覺得可以用 SQL，但考量到資料數成長後，scale 會變得困難，因此會使用NoSQL
    - 可以用 Cassandra 這種 wide-column datastore 來儲存不會很複雜的資料，在水平擴展上也很方便，不需要太多繁瑣的設定，在面對極致的寫入效能及分散式容錯是個很好的選擇，也會維護一定數量的副本 replicas，來提高可靠性
4. Component Design
    8. 傳統語言如果一個請求占用一個執行緒，遇到大量用戶上傳會造成執行緒卡死，並且500個 連線很快被分配完，因為作業系統能負荷其切換的執行緒有限，但現代的語言突破使用非同步/事件驅動模型，在上傳時部會占用一個執行緒，而是把它交給底層處理，執行緒可以轉去處理其他請求。
    9. 照片上傳、動態牆讀取拆分成兩個服務，因為上傳會占用大量的網路頻寬、記憶體與磁碟 I/O，因此可能拖垮讀的請求。拆的好處還有可以根據需求獨立擴展，例如開 50 台便宜的機器處理讀取、10台網路強的機器處理上傳。
5. sharding
在處理 User 與 Photo 關聯時，分片鍵 (Partition Key) 的選擇是面試大考點：
❌ 策略 A：Shard by UserID (將同一用戶的所有照片放同一個 Shard)
    - *直覺優點*：查詢個人主頁極快。
    - *致命缺點*：
        1. **名人效應 (Hot Users)**：超級網紅發文會瞬間塞爆單一 Shard (Hotspot) 。
        2. **分佈不均**：重度用戶與幽靈用戶會導致各 Shard 儲存空間消耗不均 。
        3. **容量上限**：若單一用戶資料大到 Shard 裝不下，拆分會增加延遲 。
        4. **單點故障 (SPOF)**：該 Shard 掛掉，該用戶的所有資料都無法存取 。
✅ 策略 B：Shard by PhotoID (以照片為單位均勻打散)
    - 完美解決了上述熱門用戶與分佈不均的問題 。
    - *新挑戰*：如何生成全域唯一的 `PhotoID`？（不能依賴單機 Auto-increment） 
6. 分散式 ID 生成 (Distributed ID Generation)
為了解決分片環境下的 ID 重複問題，常見兩種做法：
    10. **Even/Odd 雙主鍵資料庫 (active-active)**：
        - 架設兩台專門生成 ID 的 DB，透過設定 `auto-increment-offset` 與 `auto-increment-increment` 。
        - Server 1 產奇數 (1, 3, 5...)，Server 2 產偶數 (2, 4, 6...) 。
        - 透過 Load Balancer 分發請求，完美解決單點故障 (SPOF) 。
    11. **Twitter Snowflake (雪花演算法)**：
        - 生成 64-bit 的整數 ID 。
        - 結構包含：`Epoch Time (時間戳)` + `Shard/Machine ID` + `Sequence ID` 。
        - *優點*：全域唯一、自帶時間排序 (`ORDER BY PhotoID` 等同於按時間排序，免建時間索引) 。
*(註：新增 User 時的 *`*UserID*`* 也是透過相同機制生成全域唯一 ID 後，再進行 Sharding。)*
7. 未來擴充的殺手鐧：邏輯分片 (Logical Partitioning)
為了解決未來擴充實體機器時的資料大搬風，應採用**邏輯分片** 。
    - **做法**：初期就在程式內切出大量的「邏輯分片」（如 1000 個），並將它們對應到少量的「實體伺服器」（如 10 台） 。每台伺服器運行多個資料庫執行個體 。
    - **擴充時**：當實體機器滿載，只需增加新機器，並將部分「邏輯分片」直接無痛搬移至新機器 。
    - **維護**：透過一個 Config 檔案或設定檔來記錄 `邏輯分片 -> 實體伺服器` 的對應關係，更新即可完成擴容 。
8. 動態牆
    12. 直覺的作法: 打開APP → 撈取追蹤名單 → 去資料庫撈每個人最新的100張照片 → 進行 sorting 與 merging → 回傳
    13. 缺點:  high latency, 跨表 join 及即時排序
    14. 解決方案: 預先生成 (Pre-generating News Feed)，提早算好存在獨立的  userNewsFeed 資料表中 ( in-memory cache)，利用 background workers
    15. 新貼文產生時，如何推送
        1. A: pull，客戶端定期發請求，或是更新頁面時才向伺服器要資料
            1. 缺點:資料不即時，浪費資源，因為沒新貼文可能會空回應
        2. B: push，透過長輪詢(Long Polling) 或 websockets 將資料推送到粉絲的手機/ 快取中
            2. 缺點: 如果是個名人，伺服器要瞬間執行上億次的 push，足以癱瘓系統
        3. CL hybrid，一般用戶，採用 push，名人/高頻發文者，採用 pull，當載入動態牆時，才拉取名人的最新貼文並與快取內的資料合併
    16. 引入 Message Queue 實現非同步處理
        4. 發文 → web server 資料存入db → 發送 new_post_event 到 mq → 立即回傳 (low latency)
        5. background workers 監聽  queue → 取出任務 → 更新粉絲的 userNewsFeed
        6. 優點: 解偶、保護資料庫不被瞬間流量打掛、提升發文者體驗
    17. 引入 CDN
        7. 照片影片檔案如果龐大，全靠單一地區的資料中心，跨海傳輸的延遲會破壞使用者體驗
        8. 將熱門照片站存至全球各地的邊緣節點(edge server)，當台灣使用者讀取照片時，直接用位於台北的 CDN 供檔
    18. 引入 Caching
        9. 在 web server 即  db 之間部屬快取叢集，快取 metadata 等等資訊
        10. 記憶體昂貴，不可能把全部的照片資訊都放進 cache，可以使用淘汰策略 (LRU)，將最久沒有讀取的資料踢出
        11. 80-20 法則: 每天80%的讀取流量，通常集中在 20% 的熱門內容上，因此配置每日讀取資料總量的20%即可，用以節省成本

