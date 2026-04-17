---
notion-id: 3065a6e2-1812-8008-abc5-d6a0114a3bab
---
1. 釐清需求
    1. 功能性需求
        1. 用戶上傳一段文字，系統回傳唯一的  URL ex: pastebin.com/abc1234
        2. 訪問該URL時，顯示原本的文字內容
        3. 可以設定多久後自動消失 ex: 1hour, 1day, **permanent**
        4. 可以自訂網址後綴 alias
    2. 非功能性需求
        5. 高可靠性(reliability) ，用戶上傳的資料不能遺失
        6. 高可用性(availability)，系統隨時能讀取
        7. 低延遲(latency)，回傳網址的文字要快速
2. 估算系統規模
    3. 流量: 讀寫筆 5:1
        8. 假設每天 1M筆 新貼文，每篇平均 10 KB
        9. 每天新增 1M x 10 KB = 10 GB
        10. 保存10年 10 x 365 x 10 = 36TB
3. 儲存層
    4. 因為資料庫不擅長存這種長文本，每次查詢拖出 10 KB 的資料，會讓資料庫 I/O 負擔重
    5. 分兩個儲存系統
        11. 資料庫
            1. 存 Metadata，ex: paste key, userId, createdAt, expiredAt, file path
            2. 不需要太多join且儲存資料數億，需要做 sharding，還是會以NoSQL 會比較適合(Cassandra/DynamoDB)
        12. 物件儲存
            3. 存用戶貼的文字
            4. 類型: AWS S3、Google Cloud Storage…
            5. 把文字存成一個檔案，上傳上去，並把路徑存至 metadata db
4. API 設計
    6. addPaste (api_dev, paste_data, custom_url, userId, expired_date)
        13. 回傳 url 讓文字可以被取得，失敗回錯誤
    7. getPaste (api_dev_key, api_paste_key)
    8. deletePaste (api_dev_key, api_paste_key)
5. Component Design
    9. Applicatino layer
        14. 收到用戶新增request → 建立隨機6碼key (如果沒提供custom key)→ 上傳內容至 object db → 新增相關資訊至db(metadata, file_path) → 回傳url給使用者
            6.  key 有可能重複，需要重複insert至成功為止。custom key 重複直接回傳錯誤
        15. 如果要解決會重複的問題，可用 KGS (key-Db)，先預先生成很多的 key，當需要時直接拿來做使用
            7. single point of failure，可以有個備用 replica，當primary掛掉後可以還能使用
            8. 可以先把一些key放進 memory加快回傳速度，如果server死掉了那些key會還沒使用過就遺失，但因為db有數億個，因此損失可以忽略不計
6. Cleanup
    10. lazy cleanup: 讀取時，系統發現過期了，觸發刪除 S3 及 DB紀錄，回傳404
    11. scheduled Cleanup: 使用背景服務，定期掃描過期的資料並刪除

| **特性** | **SQL (關聯式)** | **NoSQL (非關聯式)** |
| --- | --- | --- |
| **分片原理** | Range, Hash, Consistent Hash (原理相同) | Range, Hash, Consistent Hash (原理相同) |
| **誰來分片** | **Application Layer** (開發者自己寫程式控制) | **Database Layer** (資料庫自動處理) |
| **跨分片查詢** | **極難** (無法 JOIN) | **不支援** (設計上就避免 Join) |
| **擴展性** | **垂直擴展** (買更強的機器) 為主，水平擴展痛苦 | **水平擴展** (加機器) 為主，非常容易 |
| **Replication** | Master-Slave (寫入瓶頸在 Master) | Master-Slave 或 Peer-to-Peer (可多點寫入) |
| **一致性** | **ACID** (強一致性) | **BASE** (最終一致性) |
