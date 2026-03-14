
## Overview

MS project 遇到三種查詢效能問題，透過逐步分析和優化，最終將查詢時間從 20 秒降至 1 秒以內。

```
問題一：分頁列表查詢（UNION ALL + ORDER BY）  20s → 1s
問題二：統計聚合查詢（COUNT + AVG，無 LIMIT）  16s → 1.1s
問題三：深度分頁（第 1500 頁很慢）             理論解法：Keyset Pagination
```

---

## 問題一：分頁列表查詢（20s → 1s）

### A. 初始問題（20 秒）

瓶頸：`(SELECT A) UNION ALL (SELECT B) ORDER BY ... LIMIT 100`

```sql
(SELECT * FROM transaction_logs WHERE type = 'income' ...)
UNION ALL
(SELECT * FROM transaction_logs WHERE type = 'expense' ...)
ORDER BY confirmedAt DESC
LIMIT 100
```

原因：資料庫被迫先找出 A 和 B 的**全部**資料（可能幾十萬筆），UNION 成百萬筆的超大結果集，然後對這百萬筆資料排序，最後才取 100 筆。效能殺手是「超大結果集排序」。

---

### B. 優化 1：Top-N per group（20s → 4-5s）

方案：將 `ORDER BY` 和 `LIMIT` 推入每個子查詢。

```sql
(SELECT * FROM transaction_logs WHERE type = 'income' ... ORDER BY confirmedAt DESC LIMIT 100)
UNION ALL
(SELECT * FROM transaction_logs WHERE type = 'expense' ... ORDER BY confirmedAt DESC LIMIT 100)
ORDER BY confirmedAt DESC
LIMIT 100
```

原理：

```
原本：A 的全部 + B 的全部 → 百萬筆 → 排序 → 取 100
優化：A 的 top 100 + B 的 top 100 → 200 筆 → 排序 → 取 100

排序成本：百萬筆 → 200 筆，大幅降低
```

---

### C. 優化 2：覆蓋索引（4-5s → 1.2s）

用 `EXPLAIN` 分析發現：`WHERE` 條件中的 `isFromCustomer = 1` 不在現有索引內，導致 Table Lookup（回表查找）。

```
原本索引：(archivedAt, confirmedAt, ...)
查詢條件：WHERE isFromCustomer = 1

執行流程：
掃描索引 → 找到候選 row → 回原表查 isFromCustomer → 不符合 → 丟棄
這個「回表查找」在大量資料下非常昂貴
```

解法：建立新的覆蓋索引，包含 `isFromCustomer`：

```sql
CREATE INDEX idx_logs_report_cover
ON transaction_logs (archivedAt, isFromCustomer, confirmedAt, ...);
```

搭配強制使用索引：

```sql
SELECT ... FROM transaction_logs USE INDEX (idx_logs_report_cover)
WHERE isFromCustomer = 1 ...
```

覆蓋索引的原理：索引本身包含查詢所需的所有欄位，不需要回原表，直接從索引取得結果。

---

### D. 優化 3：App 層預先篩選（1.2s → 1s）

問題：加入 JOIN 條件 `bankAccount.bankAccountFeeGroupId = 61` 後，查詢惡化回 3 秒。

原因：Post-Join Filter（後置過濾）的惡性循環：

```
掃描 transaction_logs 索引
    → JOIN bankAccount
    → 檢查 bankAccountFeeGroupId = 61
    → 不符合 → 丟棄這筆紀錄
    → 回去繼續掃描 logs 索引
    → 重複...
```

大量的「掃描 → JOIN → 過濾 → 丟棄」造成嚴重浪費。

解法：App 層預先篩選，把過濾條件「前置」到索引掃描層：

```js
// Step 1：App 層先查出符合條件的 ID 列表（輕量查詢）
const bankAccountIds = await BankAccount.findAll({
  where: { bankAccountFeeGroupId: 61 },
  attributes: ['id']
})
const ids = bankAccountIds.map(b => b.id)  // [3510, 3512, ...]

// Step 2：將 ID 列表注入主查詢的 WHERE，移除 JOIN 過濾
const logs = await TransactionLog.findAll({
  where: {
    bankAccountId: { [Op.in]: ids },  // IN 條件直接命中索引
    // 不再需要 JOIN bankAccount 做過濾
  }
})
```

效果：

```
原本：掃描 → JOIN → 過濾（大量丟棄）
優化：先縮小 ID 範圍 → 掃描時直接命中，幾乎不丟棄
```

---

## 問題二：統計聚合查詢（16s → 1.1s）

### A. 初始問題（16 秒）

查詢：`COUNT(*)` 和 `AVG(TIMESTAMPDIFF(...))` 統計整個月資料，沒有 `LIMIT`，必須掃描全部。

兩個瓶頸：

```
瓶頸 1：Table Lookup
SELECT 需要 appliedAt（用於 AVG），舊索引沒有包含這個欄位
→ 每筆資料都要回原表查 appliedAt

瓶頸 2：Join Lookup
INNER JOIN bankAccount ... AND archivedAt = 0
INNER JOIN platform ... AND archivedAt = 0
→ 每一筆紀錄都要 JOIN 兩張表做額外檢查
```

曾嘗試建立新索引 `IDX_LOGS_REPORT_COVER_V2`，但遺漏了 `isFromCustomer`，導致索引無效，查詢仍需 16 秒。

這個錯誤提醒：**覆蓋索引必須包含 WHERE 條件中的所有欄位，漏掉任何一個都會讓索引失效。**

---

### B. 優化 1：完整覆蓋索引（16s → 3s）

建立正確且完整的覆蓋索引：

```sql
CREATE INDEX idx_logs_report_cover_v2
ON transaction_logs (
  archivedAt,          -- 等值查詢
  isFromCustomer,      -- 等值查詢（之前遺漏的）
  confirmedAt,         -- 範圍查詢
  platformId,          -- WHERE / JOIN 欄位
  type,
  bankCategoryType,
  bankAccountId,
  appliedAt,           -- SELECT 需要（用於 AVG）
  amount               -- SELECT 需要
);
```

覆蓋索引的判斷原則：

```
WHERE 條件欄位    → 必須包含
JOIN 條件欄位     → 必須包含
SELECT 欄位       → 必須包含（這樣才不需要回表）
ORDER BY 欄位     → 建議包含
```

結果：消除了 Table Lookup（瓶頸 1），從 16s 降至 3s。剩下的 3s 全部是 Join Lookup（瓶頸 2）的成本。

---

### C. 優化 2：業務邏輯簡化（3s → 1.1s）

關鍵發現：確認了業務邏輯「有交易紀錄的 platform 和 bank_account 不會被封存」。

這代表 `INNER JOIN ... AND archivedAt = 0` 的兩個 JOIN 是多餘的，transaction_logs 裡的每一筆資料，其對應的 platform 和 bank_account 的 archivedAt 一定是 0，不需要再 JOIN 去驗證。

```sql
-- 之前（含多餘 JOIN）
SELECT COUNT(*), AVG(TIMESTAMPDIFF(SECOND, appliedAt, confirmedAt))
FROM transaction_logs
INNER JOIN bank_accounts ON ... AND bank_accounts.archivedAt = 0
INNER JOIN platforms ON ... AND platforms.archivedAt = 0
WHERE ...

-- 之後（移除多餘 JOIN）
SELECT COUNT(*), AVG(TIMESTAMPDIFF(SECOND, appliedAt, confirmedAt))
FROM transaction_logs
WHERE ...
```

結果：查詢變為純 Index-Only Scan，MySQL 完全不需要碰原表，效能達到極致，降至 1.127s。

**這個優化的啟示：效能問題不只有技術解法，有時候用業務邏輯來簡化查詢更有效。**

---

## 問題三：深度分頁（第 1500 頁很慢）

### 問題

第 1 頁（`LIMIT 0, 100`）：1 秒。 第 1500 頁（`LIMIT 150000, 100`）：非常慢。

### 原因：OFFSET 的天生缺陷

```
子查詢的 LIMIT 必須是 1500 * 100 + 100 = 150100

執行流程：
兩個子查詢各掃描超過 15 萬筆紀錄
UNION 合併（30 萬筆）
排序
丟棄前 15 萬筆
最後取 100 筆

成本全消耗在「掃描並丟棄」15 萬筆資料上
```

OFFSET 越大，需要掃描並丟棄的資料越多，是線性增長的效能問題。

---

### 解法：Keyset Pagination（游標分頁）

原理：不用頁碼和 OFFSET，改用「上一頁最後一筆的值」作為游標。

```sql
-- 第一頁
SELECT * FROM transaction_logs
WHERE ...
ORDER BY confirmedAt DESC, id DESC
LIMIT 100

-- 下一頁（傳入上一頁最後一筆的 confirmedAt 和 id）
SELECT * FROM transaction_logs
WHERE ...
AND (confirmedAt, id) < ('2024-01-15 10:30:00', 5000)
ORDER BY confirmedAt DESC, id DESC
LIMIT 100
```

為什麼用複合條件 `(confirmedAt, id)`：

```
如果多筆資料有相同的 confirmedAt
→ 只用 confirmedAt 無法唯一確定位置
→ 加上 id 作為 Tie-Breaker，保證唯一性和正確的排序
```

效果：

```
OFFSET 方式：第 1500 頁需掃描 150000 筆 → 很慢
Keyset 方式：WHERE 條件直接命中索引位置 → 和第 1 頁一樣快
```

Trade-off：

```
優點：任何頁碼都和第 1 頁一樣快，O(1) 而非 O(n)
缺點：失去「跳頁」功能，只能「上一頁 / 下一頁」
      游標必須是有索引的排序欄位
```

**注意：MS 專案最終未採納這個方案**（可能因為 UI 需要跳頁功能），但這是業界標準的深度分頁解法。

---

## 效能調校工具：EXPLAIN

每次優化前都應該用 `EXPLAIN` 分析，確認問題所在：

```sql
EXPLAIN SELECT * FROM transaction_logs WHERE ...
```

重點欄位：

```
type：
  ALL   → 全表掃描，最差
  index → 全索引掃描，次差
  range → 範圍索引掃描，可接受
  ref   → 非唯一索引查找，好
  const → 唯一索引查找，最好

key：實際使用的索引（NULL 代表沒有用到索引）

Extra：
  Using index          → Index-Only Scan，最理想（不需回表）
  Using where          → 有過濾條件
  Using filesort       → 需要額外排序，可能是瓶頸
  Using temporary      → 使用暫存表，效能差
```

---

## 核心原則總結

```
1. 用 EXPLAIN 找瓶頸，不要猜
   → 先確認問題是 Table Lookup、Join Lookup 還是排序

2. 覆蓋索引要完整
   → WHERE + JOIN + SELECT + ORDER BY 的欄位都要考慮進去
   → 漏掉任何一個都會讓索引失效，導致 Table Lookup

3. Top-N per group
   → UNION ALL 的子查詢要各自加 ORDER BY + LIMIT
   → 讓每個子查詢只回傳必要的資料，避免超大結果集

4. 後置過濾（Post-Join Filter）很貴
   → 用 App 層預先篩選，把過濾條件前置到 WHERE
   → 減少「掃描 → JOIN → 丟棄」的循環

5. 業務邏輯可以簡化查詢
   → 了解資料的業務約束，移除多餘的 JOIN 或條件
   → 有時比純技術手段更有效

6. 深度分頁用 Keyset Pagination
   → OFFSET 是線性成本，頁碼越大越慢
   → Keyset 每頁都 O(1)，代價是失去跳頁功能
```

---

## Interview Answer

「MS 專案有一個報表查詢原本要 20 秒，我透過三步優化降到 1 秒。

第一步是查詢結構優化，原本 `UNION ALL` 後才做 `ORDER BY LIMIT`，資料庫要對百萬筆資料排序。我把 `ORDER BY LIMIT` 推入每個子查詢，讓每個子查詢只回傳 100 筆，最終只需對 200 筆排序。

第二步是建立覆蓋索引，用 `EXPLAIN` 發現 `isFromCustomer` 不在索引裡，導致大量 Table Lookup。我建立了包含所有 `WHERE` 和 `SELECT` 欄位的覆蓋索引，消除回表查找。

第三步是把 JOIN 的過濾條件移到 App 層，先用輕量查詢取得符合條件的 ID 列表，再用 `IN` 注入主查詢，把後置過濾變成前置過濾，完全消除 Post-Join Filter 的惡性循環。

另外還有一個統計查詢從 16 秒降到 1.1 秒，除了建立完整覆蓋索引外，最關鍵的是發現業務邏輯上兩個 `INNER JOIN` 是多餘的，直接移除後變成純 Index-Only Scan。」

---

## Related Topics

- [[MySQL Index]] — Covering Index, Composite Index, EXPLAIN 解讀
- [[MySQL Lock]] — SELECT FOR UPDATE, Gap Lock
- [[MS Project]] — 系統架構總覽