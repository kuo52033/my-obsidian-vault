---
notion-id: 3385a6e2-1812-807a-95a9-c53c7a47201f
base: "[[New database.base]]"
指派: []
狀態: 進行中
---
### Situation（背景）

金融管理系統的交易報表查詢頁面在資料量增長後，API 回應時間飆升到 **20 秒**，使用者幾乎無法正常使用。這是一個核心的分頁列表查詢，涉及多表 JOIN 和 UNION ALL 合併兩種類型的交易紀錄。另外還有統計聚合查詢（COUNT / AVG）耗時 16 秒。

### Task（任務）

由我負責排查 SQL 效能瓶頸並優化，目標是將核心查詢降到可接受的回應時間（秒級）。

### Action（行動）

**優化歷程 1：分頁列表查詢 20s → 1s**

**Step 1 — 查詢結構優化（20s → 4~5s）**

- 原始寫法：`(SELECT A) UNION ALL (SELECT B) ORDER BY ... LIMIT 100`
- 問題：DB 被迫把 A 和 B 的全部資料（數十萬筆）UNION 成一個超大結果集，再對百萬筆排序，最後才取 100 筆
- 改為 **Top-N per group** 模式：把 `ORDER BY ... LIMIT 100` 推入每個子查詢內部，最後只對 200 筆做排序

**Step 2 — 索引優化（4~5s → 1.2s）**

- 用 `EXPLAIN` 分析，發現 WHERE 條件中的 `isFromCustomer` 欄位不在索引中，導致每筆資料都需要 **回表查找（Table Lookup）**
- 建立**覆蓋索引（Covering Index）** `idx_logs_report_cover`，包含所有 WHERE、ORDER BY 和 SELECT 需要的欄位
- 使用 `USE INDEX` hint 強制優化器使用正確的索引

**Step 3 — 消除 Post-Join Filter（1.2s → 1s）**

- 加入 JOIN 條件 `bankAccount.bankAccountFeeGroupId = 61` 後查詢惡化回 3s
- 原因：觸發「後置過濾」— DB 掃描索引 → JOIN → 檢查條件 → 不符合就丟棄，形成掃描-查找-丟棄的惡性循環
- 解法：**應用層預先篩選** — 先用一筆輕量查詢取得符合條件的 ID 列表，再注入主查詢的 `WHERE IN (...)` 子句，把過濾條件「前置」到索引掃描層

**優化歷程 2：統計聚合查詢 16s → 1.1s**

- 問題：`COUNT(*)` 和 `AVG()` 需要掃描整月資料，且索引缺少 `appliedAt` 欄位導致回表
- Step 1：建立完整的覆蓋索引，消除 Table Lookup（16s → 3s）
- Step 2：確認業務邏輯「有交易紀錄的帳戶不會被封存」，因此 `INNER JOIN ... AND archivedAt = 0` 是多餘的 → 移除 JOIN，查詢變為**純索引掃描（Index-Only Scan）**（3s → 1.1s）

### Result（成果）

- 分頁列表查詢從 **20 秒降至 1 秒**（提升 95%）
- 統計聚合查詢從 **16 秒降至 1.1 秒**（提升 93%）
- 報表頁面從「幾乎不可用」變為「即時回應」，使用者體驗大幅改善
- 過程中建立的索引優化和查詢改寫方法論，後續應用到其他慢查詢的排查

### 