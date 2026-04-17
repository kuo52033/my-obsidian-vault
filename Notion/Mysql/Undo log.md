---
notion-id: 878cd3b4-02f4-4213-966e-d8598335438f
---
> [!tip] 💡
> 當執行 transaction 到一半失敗了需要把前面執行過的 SQL rollback，每當我們要對一筆紀錄做修改時(insert, update delete) ，會把 rollback 所需的的東西記錄下來，而這些內容則稱為 undo log，實現 ACID 的 原子性

對於 InnoDB 引擎來說，每行紀錄除本身的資料外，還有幾個隱藏的欄位

- DB_ROW_ID: 沒有 primary key 或 unique key 時自動新增此欄位作為主鍵
- DB_TRX_ID: 每個 transaction 都會分配到一個 id，如果某筆資料發生了變動，會將該id 寫入此欄位
- DB_ROLL_PTR: 指向 undo log