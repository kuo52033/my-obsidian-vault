---
notion-id: cd03e4af-12fb-4713-8c75-bd69dcbada82
---
索引是一種資料庫結構，可以幫助快速查詢資料庫表中的資料。索引的工作方式有點像書的索引：不必從頭到尾讀取整本書來找到所需的信息，而是可以在索引中查找關鍵字，然後直接跳到包含該信息的頁面。同樣，資料庫索引允許資料庫查詢引擎快速找到儲存在表中的行，而不必掃描整個表。

- index is a seperate data structure
- it copy a part of your data
- without the index, mysql must begin with the first row and then read through the entire table to find the relevant row
- primary key automatically creates the unique index 
- query drive the index

## B+ tree

### Primary key index (only one)

![[螢幕擷取畫面_2024-02-25_164040.png]]

primary key equal to table,  all the data is stored in the leaf node

### Secondary key index (has many)

![[螢幕擷取畫面_2024-02-25_165350.png]]

leaf nodes contain the data that we have indexes

every secondary key leaf node have point (primary key (id)) back to the raw in order to do the second lookup

---

Cardinality (基數):  a number of unique values in a row 

- select COUNT( DISTINCT(column_name) ) from table_name

Selectivity: is the ratio of cardinality to the number of records of an indexed column.

- select COUNT( DISTINCT(column_name) ) / COUNT(*) from table_name

If the ratio is 1, it means all the records in a row are unique and is also referred to as high selectivity. Choose the index with high selectivity.

Practical guidance:

- High selectivity (close to 1): `email`, `user_id` — index is very effective, narrows results quickly
- Low selectivity (close to 0): `gender`, `status` (0/1) — index may be less useful; MySQL might choose a full table scan instead

For composite indexes, put the highest selectivity column on the left.

---

## Composite indexes

The order of columns in a composite index is critical. The B+ tree sorts by the leftmost column first, then the next column for equal values, and so on.

### Rules

- Start at left to right, no skipping columns
- Stops being effective after the first range condition
- ID is always at the rightmost

### Why range stops the index

Given index `(a, b, c)` and query `WHERE a = 1 AND b > 5 AND c = 3`:

Within the range `b > 5`, the values of `c` are unordered — because `c` ordering is only guaranteed when `b` is equal. So MySQL cannot use the index to locate `c = 3` and must scan all rows matching `b > 5`.

### Design principle

Put equality conditions first, range conditions last.

For example, prefer `(isFromCustomer, confirmedAt)` over `(confirmedAt, isFromCustomer)` when `isFromCustomer` is an equality condition and `confirmedAt` is a range.

---

## Covering indexes

Covering indexes describe a situation in which an index covers the entire set of needs for a single query. It only uses the index and does not hop back to the clustered index (no Table Lookup).

For a covering index to work, the index must include **all** columns referenced in:

- `WHERE` conditions
- `JOIN` conditions
- `SELECT` columns
- `ORDER BY` columns

Missing even one column forces a Table Lookup.

In `EXPLAIN`, a covering index shows `Using index` in the Extra column — this is the best possible state.

(select only ID case)

---

### 為什麼不用 binary search tree

- 因為他是以第一插入的資料作為根結點，有可能會出現線性結構，這樣就跟全表掃描一樣。

### 那 balanced binary search tree 呢

> [!note]+ 特點
> - 高度差不超過1
> - 左右子樹都是平衡樹
> - time complexity O(log(n))

- 雖然可以防止線性結構的出現，但搜尋效率不足，資料所處的深處，決定搜尋的 I/O 次數(每個節點大小為一頁大小)，當資料很多時樹的高度會很恐怖。
- 查詢不穩定，資料位於根節點或葉節點相差很大。
- 儲存的資料內容太少，os 和 disk 的資源交換以頁為單位(4kb)，每一次的 I/O process 會將 4k 的資源載入記憶體，但在二元樹每個節點只存 index、data、two references，填不滿一頁的大小，在做很多次 I/O process 時會沒很好利用這個特性。

## B tree (balance tree)

![[no73e8xxub.png]]

> [!note]+ 特點
> - m 階 B tree，每個節點最多 m 個子樹，每個節點最多存 m-1 個子節點
> - 每個子節點都放完整資料
> - 絕對平衡樹
> - 為了二元樹解決高度太高的問題

### 為何解決

- mysql 為了利用磁碟的預讀能力，將page設定為16k，這樣能夠存非常多的 index 及數據，I/O 次數會大大減少
- 降低樹高，增加節點儲存量

> [!note]+ 缺點
> - 查詢不穩定
> - 範圍搜索沒效率
> - 資料量太大節點可能放不下

## B+ tree

![[20089358gVvqssFgqR.png]]

> [!note]+ 特點
> - m 階 B tree，每個節點最多 m 個子樹，每個節點最多存 m-1 個子節點
> - 只有葉子放完整資料
> - 非葉子節點只放索引
> - 葉子節點會包含一個指針指向右邊的葉子節點

### B+ tree 及 B tree 的差異

- B+ tree 資料只保存在葉節點，因此每次搜尋都會保證到葉節點，而 B tree 如果有命中就會回傳
- B+ tree 葉節點會像是 linked list 一樣，有順序排列，葉節點之間會有連接

### mysql 為何選擇 B+ tree

- 在做範圍或全域搜索會更加出色，因葉節點之間有連接，而 B tree 有可能需要把整棵樹都遍歷一遍
- 因為根及枝節點不存資料，因此可以存更多的 index，一次 I/O 載入的 index 會比 B tree 更多，深度更低，I/O次數減少
- B+ tree 天然具有排序能力
- B+ tree 的查詢 I/O 次數是穩定的

### I/O cost per query

Each node traversal in a B+ tree = one I/O (one page read). MySQL sets the page size to 16KB, so each node can store a large number of index entries.

A tree of height 3 can index roughly 1 billion rows, requiring only 3 I/O operations to reach a leaf node.

For a Secondary Index query with Table Lookup:

- Walk Secondary Index B+ tree: ~3 I/O (reach leaf, get primary key)
- Walk Primary Key B+ tree: ~3 I/O (reach leaf, get full row)
- Total: ~6 I/O

For a Covering Index (Index-Only Scan):

- Walk Secondary Index B+ tree: ~3 I/O
- No Table Lookup needed
- Total: ~3 I/O

---

## Table Lookup (回表查找)

When a Secondary Index query needs columns not present in the index, MySQL must perform a second B+ tree traversal using the primary key retrieved from the secondary index leaf node. This second traversal is the Table Lookup.

Example:

```javascript
SELECT * FROM users WHERE email = 'tim@gmail.com'

Step 1: Walk email Secondary Index → find leaf node → get primary key id = 42
Step 2: Walk Primary Key Index with id = 42 → get full row data  ← Table Lookup
```

Table Lookup is expensive at scale. The goal of index design is to minimize or eliminate it.

---

## Index Condition Pushdown (ICP)

A MySQL optimization (since 5.6) that pushes filter conditions down to the Storage Engine layer, before the Table Lookup.

### When ICP applies

ICP applies when:

1. A composite index is used
2. The index scan stops at a range condition
3. There are additional conditions on columns that exist in the index (but after the range)

Example:

```javascript
Index: (bankAccountId, confirmedAt, platformId)

Query: WHERE bankAccountId = 5
         AND confirmedAt > '2024-01-01'   -- range, index scan stops here
         AND platformId = 3               -- ICP applies here
```

Without ICP:

```javascript
Storage Engine: scan index for bankAccountId=5 AND confirmedAt > '2024-01-01'
→ return 1000 primary keys to Server layer
→ Table Lookup 1000 times
Server layer: filter platformId = 3 → discard 900 rows
Result: 100 rows, but 900 Table Lookups wasted
```

With ICP:

```javascript
Storage Engine: scan index, check platformId = 3 directly on the index
→ skip non-matching rows before Table Lookup
→ only 100 rows pass the filter
→ Table Lookup 100 times
Result: 100 rows, 900 Table Lookups saved
```

### ICP in EXPLAIN

| Extra value | Meaning |
| --- | --- |
| `Using index` | Covering index, no Table Lookup at all (best) |
| `Using index condition` | ICP active, filtering at Storage Engine layer |
| `Using where` | Filter applied at Server layer after Table Lookup |

### ICP limitations

- Only applies to Secondary Indexes (not Primary Key Index)
- Only uses columns already in the index
- Enabled by default (MySQL 5.6+), no manual configuration needed
- When using a Covering Index, ICP is irrelevant (no Table Lookup anyway)

### Three levels of index efficiency

| Level | Situation | Extra in EXPLAIN |
| --- | --- | --- |
| Worst | No index on WHERE column | (full table scan) |
| Better | Index + ICP | `Using index condition` |
| Best | Covering Index | `Using index` |

---

## Index Design Principles

4. **Query-driven** — design indexes based on actual queries (WHERE, JOIN, ORDER BY, SELECT), not the table structure
5. **High selectivity columns on the left** of composite indexes
6. **Equality conditions before range conditions** in composite index column order
7. **Covering index must be complete** — include all columns from WHERE, JOIN, SELECT, ORDER BY; missing any one causes Table Lookup
8. **Be aware of low-selectivity columns** — MySQL may ignore the index and do a full table scan if selectivity is too low
9. **Indexes have write overhead** — every INSERT/UPDATE/DELETE must also update all relevant indexes; don't over-index