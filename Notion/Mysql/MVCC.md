---
notion-id: e2456036-f494-498a-96ea-e790d473ae76
---
> [!tip] 💡
> MVCC (multi-version concurrency control) ，在併發環境下進行的資料安全控制，解決寫-讀、寫-讀併發操作，屬於樂觀鎖，在 read commited 及 repeatable read  隔離等級下可實現。

### Read View

read view 為一個列表，用來存放當前資料庫中活耀的讀寫事務，也就是正在進行資料操作但還尚未提交的 transaction，可以來判斷某個版本是否對目前的 transaction 可見，有四個重要欄位

![[螢幕擷取畫面_2024-06-07_181514.png]]

- creator_trx_id: 目前 read view 所對應的 transaction id
- m_ids: 活躍的 transaction 列表(尚未提交)
- min_trx_id: m_ids 中最小的
- max_trx_id: 創建 read view 時當前資料庫中應該給下一個事務的id 值