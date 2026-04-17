---
notion-id: 3055a6e2-1812-8028-9e75-f54c235499b9
---
1. 釐清需求(requirement)
    - 功能性需求
        - 縮短網址 : 輸入長網址 → 系統產生短網址 (unique)
        - 重新導向 : 點擊短網址 → 系統導回原長網址
        - 自訂別名 : ex: tinyurl.com/my-link
        - 過期時間 : 短網址自動過期
    - 非功能性需求
        - 高可用性 High Available : 服務不掛，否則短網址失效
        - 低延遲  low latency : 重新導向 快
        - 安全性 : 短網址不容易被猜到
2. 估算系統規模
    - 流量
        - 讀多寫少 ex: 100:1
        - 寫入: 500M/month 
            - QPS: 500000000/2592000 大約 200 url/s
        - 讀取: 500M * 100 = 50 B/ month
            - QPS : 200 * 100 = 20k url/s
    - 儲存
        - 假設保存資料5年
            - 500 M * 12 * 5 = 30 B 資料
            - 30 B * 500 bytes 大約 15TB
3. 資料庫設計
    - SQL
        - 優點
            - 結構嚴謹
            - 透過unique ley 保證不重複
        - 缺點
            - 存數十億筆資料 → 單台扛不住 → 需做複雜的 sharding
            - 資料大多沒關聯性，不需要 join
            - 在讀多寫少的情況，NOSQL 更容易水平擴展
    - NOSQL
        - 優點
            - 水平擴展性佳，增加節點即可，不須像SQL處理複雜的手動分庫分表
            - key-value 查詢高效 → shortURL → originalURL
            - 高可用性，CAP選擇了AP，即使有節點壞掉還是能繼續服務
        - 缺點
            - 無自增 ID
            - 最終一致性，新增厚，無法力可在所有結點上讀到 (通常可接受)

→ 較優選擇 : NOSQL

4. 核心演算法
    - 接受請求 → 生成key (hash or base62) → 嘗試寫入
        - 成功 →回傳短網址
        - 失敗( duplicate key ) → 重新生成 key 直到成功為止
            - 優點
                - 架構簡單
            - 缺點
                - 高流量時延遲會增加 (發生衝突) → 等待多次 RTT (資料庫網路來回時間)
                - 高併發寫入時，大量的失敗重試會佔用資料庫資源
    - KGS (key generation service) 金鑰離線生成服務
        - 預先產生好隨機生成的 base62字串，確保沒重複，並放在一個專門的資料庫
        - 當 web server 收到請求後，直接向 KGS 請求一個 key，並標記為已使用
            - 優點
                - 完全無碰撞，因為已經預先生成
                - web server 寫入速度極快
                - 安全性高，因為是隨機生成，不像自增 ID 有規律
            - 缺點
                - 如果 KGS 掛了，整個系統會無法產生新網址，需要設定備用伺服器
        - 須注意如果兩個 web server 同時搶 key 會需要使用同步鎖鎖住，不管是存在 cahce或是伺服器ram
    - hashing or encoding
        - MD5 (Hashing) : 不可逆的雜湊函示，通常是固定長度32字元16進位 128-bit，截斷後碰撞機率會變高
        - Base62(Encoding) : 可逆的變動長度字串(由 a-z、A-Z、0-9組成)，輸入不重複就不會碰撞，ex: 00001 → 3dudzs1
        - 因此採用 Base62 編碼配合唯一 ID 生成器是最優解，無碰撞不需截斷，長度短邏輯簡單，重點是隨機生成的 ID 要如何設計，可以加入 timestamp，或是用 KGS 來預先生成隨機 KEY
小規模、低寫入量 → 適合方法一
大規模、高併發 → 適合方法二

5. 擴展性與優化
    - 資料分片 ( Data Partitioning / Sharding )
        - 有數十億的資料，一台伺服器扛不住，需要將資料分散儲存到多台伺服器
            - 基於範圍: 依照第一個字母分配
                - 優點
                    - 簡單，容易預測資料在哪
                - 缺點
                    - 資料容易分配不均，如果以’A’的開頭遠多於 'Z'，導致熱shard
            - 基於雜湊 : 對key做hash，再取模數 (Modulo)來決定存哪台 ex: hash(key) % N
                - 優點
                    - 資料分散均勻
                - 缺點
                - 如果要改 N，會造成大量資料移動，可以改使用**一致性雜湊 (Consistent Hashing)，來降低資料移動數量**
    - 快取 (caching)
        - 快取熱門的網址，當快取滿了，可以採用 **LRU (Least Recently Used，最近最少使用)，把最久沒人用的網址踢掉**
    - 資料庫清理 
        - 不要用排程定期掃資料表找過期資料，會造成極大負擔
        - Lazy Cleanup
            - 當使用者試圖訪問該網址發現過期，回傳錯誤並刪除
            - 輕量級後台服務，再低峰期(半夜) 慢慢掃瞄並刪除，釋放出來的 key 放回 KGS
    - 可以利用 API key 來對使用者做rate limiting，例如每個 API key 每分鐘只能生成10個短網址，防止惡意用戶塞爆資料庫
    ## 整體流程
使用者 → get /tinyURL/asoius → load balancer → web server → 查詢 key (cache) → 命中取得長網址/未命中找NOSQL並寫入快取 → http 301 or 302 redirect → 非同步紀錄數據 (optional)

HTTP 301 ( move permanently): 告訴這個網址永遠搬家了，並會把轉址結果存在本地快取，下次輸入時不必經過 web server，缺點是無法統計點擊率
HTTP 302 ( Found/ Temporary Redirect): 這個網址暫時搬家，下次請求短網址還是會發請求給 web server，雖然伺服器負擔會比較高，但可以記錄每一次的點擊
