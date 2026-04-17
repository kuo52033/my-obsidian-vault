---
notion-id: 2a75a6e2-1812-80e9-b1a9-c5a521cba44d
---
我們主要處理了三種查詢情境：

1. **分頁列表查詢 (Top-N)**：`LIMIT 100` 的報表查詢。
2. **統計聚合查詢 (Aggregate)**：`COUNT(*)` 和 `AVG()` 的統計查詢。
3. **深度分頁問題 (Deep Paging)**：查詢第 1500 頁 (`LIMIT 150000, 100`)。

---

### 1. 分頁列表查詢 (20s -> 1s)

### A. 初始問題 (20 秒)

- **瓶頸：** `(SELECT A) UNION ALL (SELECT B) ORDER BY ... LIMIT 100`。
- **原因：** 資料庫被迫找出 A 和 B 的**所有**資料（可能幾十萬筆），`UNION` 成一個百萬筆的超大結果集，然後**對這百萬筆資料進行排序**，最後才取 100 筆。效能殺手是「超大結果集排序」。

### B. 優化 1：查詢結構優化 (降至 4-5 秒)

- **方案：「Top-N per group」**。
- **動作：** 將 `ORDER BY` 和 `LIMIT` 推入 `UNION ALL` 的子查詢中。
- **結構：**SQL
`(SELECT A ... ORDER BY ... LIMIT 100) 
UNION ALL 
(SELECT B ... ORDER BY ... LIMIT 100)
ORDER BY ... LIMIT 100;`
- **結果：** 資料庫現在只需對 `100 + 100 = 200` 筆資料進行最終排序，效能大幅提升。

### C. 優化 2：索引優化 (降至 1.2 秒)

- **瓶頸：** 4-5 秒還是太慢，`EXPLAIN` 分析發現 `WHERE` 條件中的 `isFromCustomer = 1` 沒有被包含在索引中。
- **原因：** 索引中缺少 `isFromCustomer`，導致資料庫在掃描索引時，可能需要「**回原表查找 (Table Lookup)**」來檢查這個欄位。
- **動作：**
    1. 建立一個新的「覆蓋索引」`idx_logs_report_cover`，**包含** `isFromCustomer`。
    2. 在 SQL 中使用 `USE INDEX (idx_logs_report_cover)` 強制優化器使用它。

### D. 優化 3：查詢邏輯優化 (降至 1 秒)

- **瓶頸：** 當加入 `JOIN` 條件 `bankAccount.bankAccountFeeGroupId = 61` 時，查詢惡化回 3 秒。
- **原因：** 觸發了「**後置過濾 (Post-Join Filter)**」。資料庫掃描 `logs` 索引 -> `JOIN` `bankAccount` -> 檢查 `bankAccountFeeGroupId` -> 若不符，**丟棄**這筆紀錄，然後回去繼續掃描 `logs` 索引。這是一個「掃描-查找-過濾-丟棄」的惡性循環。
- **動作：「應用程式層預先篩選」**
    1. **(App 層)** 先執行一筆輕量查詢 `SELECT id FROM bank_accounts WHERE bankAccountFeeGroupId = 61`，獲取 ID 列表 (例如 `3510, 3512, ...`)。
    2. **(SQL 層)** 移除 `JOIN` 上的過濾，將 ID 列表注入主查詢的 `WHERE` 子句：`AND transaction_logs.bankAccountId IN (3510, 3512, ...)`。
- **結果：** 過濾條件被「前置」到索引掃描層，完全消除了「後置過濾」的瓶頸。

---

### 2. 統計聚合查詢 (16s -> 1.1s)

### A. 初始問題 (16 秒)

- **瓶頸：** `COUNT(*)` 和 `AVG(TIMESTAMPDIFF(...))`。此查詢**沒有 **`**LIMIT**`，必須掃描整個月的**所有**資料。
- **原因：**
    1. **Table Lookup (回表查找)：** `SELECT` 列表需要 `appliedAt`（用於 `AVG`），但舊索引 `idx_logs_report_cover` 中沒有。
    2. **Join Lookup (JOIN 查找)：** `INNER JOIN` 必須為**每一筆**紀錄檢查 `bankAccount.archivedAt = 0` 和 `platform.archivedAt = 0`。
- **錯誤嘗試：** 您曾建立一個新索引 `IDX_LOGS_REPORT_COVER_V2`，但**遺漏了 **`**isFromCustomer**`，導致索引無效，查詢仍需 16 秒。

### B. 優化 1：正確的「完全覆蓋索引」 (降至 3 秒)

- **動作：** 我們建立了一個**正確且完整**的覆蓋索引 `idx_logs_report_cover_v2`，它包含了：
    - `archivedAt`, `isFromCustomer` (等值查詢)
    - `confirmedAt` (範圍查詢)
    - `platformId`, `type`, `bankCategoryType`, `bankAccountId` (其他 `WHERE`/`JOIN` 欄位)
    - `appliedAt`, `amount` (覆蓋 `SELECT` 和 `AVG` 計算所需的欄位)
- **結果：**
    - 成功消除了「Table Lookup」（問題 1），效能從 16 秒降至 3 秒。
    - 剩下的 3 秒**全部**是「Join Lookup」（問題 2）的成本。

### C. 優化 2：業務邏輯簡化 (降至 1.1s)

- **瓶頸：** 3 秒的「Join Lookup」成本。
- **動作：** 您確認了一個關鍵業務邏輯：「有交易紀錄的 `platform` 和 `bank_account` 不會被封存」。
- **結果：**
    - 這證實了 `INNER JOIN ... ON ... AND archivedAt = 0` 這兩個檢查是**多餘的**。
    - 我們從 SQL 中**完全移除了這兩個 **`**INNER JOIN**`。
    - 查詢變為「**純索引掃描 (Index-Only Scan)**」，效能達到極致，降至 1.127 秒。

---

### 3. 深度分頁問題 (第 1500 頁很慢)

- **問題：** 查詢第 1 頁（`LIMIT 0, 100`）很快 (1s)，但查詢第 1500 頁（`LIMIT 150000, 100`）非常慢。
- **原因：** 這是 `OFFSET` 的天生缺陷。
    - 為了「正確分頁」，子查詢的 `LIMIT` 必須是 `1500 * 100 + 100 = 150100`。
    - 資料庫被迫在兩個子查詢中各掃描超過 15 萬筆紀錄，合併 (30 萬筆) 並排序，最後**丟棄**前 15 萬筆。
    - 成本消耗在「掃描並丟棄」海量資料上。
- **最終解決方案 (未採納)：**
    - 放棄「頁碼」和 `OFFSET`。
    - 改用「**Keyset Pagination (游標分頁)**」。
    - **做法：**
        1. 排序改為 `ORDER BY confirmedAt DESC, id DESC`（`id` 作為唯一 Tie-Breaker）。
        2. App 請求「下一頁」時，傳入「上一頁最後一筆」的 `last_confirmed_at` 和 `last_id`。
        3. `WHERE` 條件改為 `(transaction_logs.confirmedAt, transaction_logs.id) < (last_confirmed_at, last_id)`。
        4. 所有 `LIMIT` 永遠保持為 `100`。
    - **優點：** 第 1500 頁會和第 1 頁一樣快（1 秒）。
    - **取捨：** 失去「跳頁」功能，只能「上一頁/下一頁」。