---
notion-id: 3085a6e2-1812-8066-abec-e239f54e91a0
---
當單一資料庫無法承受海量數據的儲存容量或讀寫流量時，將大型資料庫拆分成許多較小的部分（分片），分散儲存到多台機器上的技術。這是實現**水平擴展 (Horizontal Scaling)** 的核心手段。

> **何時需要分片？** 單機 DB 瓶頸訊號：寫入持續 > 5,000/sec、儲存 > 幾 TB、p99 延遲持續上升、CPU 長期 > 70%。在此之前優先考慮讀寫分離與快取。

---

## 1. 分片的基本策略 (Partitioning Criteria)

**Range-Based（範圍分片）**：依屬性範圍切分（如首字母、時間、Zip Code）。查詢範圍資料高效，但容易造成資料分佈不均與熱點分片。

**Hash-Based（雜湊分片）**：`Shard = Hash(key) % N`。資料分佈均勻，但增減節點時觸發大量資料搬移（Rehashing Problem）— 幾乎所有 key 的映射都改變。

**Consistent Hashing（一致性雜湊）**：透過 Hash Ring + Virtual Nodes 解決搬移問題。新增節點只影響鄰近區段，搬移量從 O(N) 降至 O(1/N)。Cassandra、DynamoDB 皆採用此方案。

### Consistent Hashing 細節

```javascript
Hash Ring（0 ~ 2^32）：
  節點 A → 映射到 ring 上位置 100
  節點 B → 映射到 ring 上位置 200
  節點 C → 映射到 ring 上位置 300

  Key K → hash(K) = 150 → 順時針找到最近節點 B → 寫入 B

新增節點 D（位置 250）：
  只有原本屬於 C（200~250 區段）的 key 需要搬移到 D
  其他節點完全不受影響 ✓

Virtual Nodes（虛擬節點）：
  每台實體機器在 ring 上放 100~200 個虛擬點
  → 將單一大區段拆成多個小區段，提高 hash 分佈均勻性
  → 利用大數法則，使資料負載接近平均
  → 節點故障時，每個虛擬區段分別轉移給不同節點，
     避免負載集中在單一鄰居
```

---

## 2. Composite Partition Key（複合分片鍵）

這是 Twitter / Cassandra 架構中最重要的分片概念。單一 Partition Key 在高活躍用戶下會造成無界成長的熱點，複合分片鍵透過加入時間維度解決。

**問題：單一 user_id 分片**

```javascript
@elonmusk 15 年共 54,750 則推文 → 全部落在同一個節點
該節點被打爆，其他節點閒置，完全違背水平擴展目的
```

**解法：加入 Bucket 時間桶**

```sql
CREATE TABLE tweets (
  user_id    BIGINT,
  bucket     TEXT,        -- 'YYYY-MM'，例如 '2025-02'
  tweet_id   BIGINT,      -- Snowflake ID（自帶時間排序）
  content    TEXT,

  PRIMARY KEY ((user_id, bucket), tweet_id)
  --           ─────────────────  ────────
  --           複合 Partition Key  Clustering Key
  --           決定存在哪個節點    決定節點內排序

) WITH CLUSTERING ORDER BY (tweet_id DESC);
```

| 部分 | 欄位 | 職責 |
| --- | --- | --- |
| 複合 Partition Key | `(user_id, bucket)` | `hash(user_id + bucket)` 決定目標節點 |
| Clustering Key | `tweet_id` | 節點內部依 tweet_id DESC 物理排序（磁碟上） |
| Bucket 粒度 | Month `YYYY-MM` | 每個 Partition 約 300 則，有界且均勻 |

**Bucket 粒度權衡**

```javascript
年 (YYYY)    → 分片太大，重度用戶仍有熱點
月 (YYYY-MM) → 推薦，每分片 ~300 則，跨月只需 2-3 次查詢
週           → 過細，讀取近 1 個月需 4+ 次查詢
日           → 過細，普通用戶每天只發 1-2 則，partition 太碎
```

**為何不直接用 tweet_id 當 Partition Key？**

```javascript
hash(tweet_id) → 每則推文隨機落在不同節點

查詢「@jack 的最新 20 則推文」：
  → 必須詢問所有 100 個節點（scatter-gather）
  → 100 nodes × 325,000 reads/sec = 3,250 萬次節點操作/sec
  → 叢集直接過載

用 (user_id, bucket) 後：
  → 直接定位到 1 個節點，循序讀取
  → 查詢時間 5-10ms ✓
```

### Secondary Index 無法解決此問題

很多人會問：「加個 user_id 的 Secondary Index 不就好了？」—— 不行。

```javascript
Cassandra 的 Secondary Index 是 Local Index（每個節點維護自己的本地索引）：

  Node 3 的本地索引: user_id=123 → [tweet_A, tweet_D, tweet_F]
  Node 7 的本地索引: user_id=123 → [tweet_C, tweet_G]
  ...

查詢 WHERE user_id = 123：
  Cassandra 依然必須詢問所有節點「你的本地索引有 user_id=123 嗎？」
  → 仍然是全叢集 scatter-gather，效能與沒有 index 一樣差

Cassandra 官方文件明確警告：
  Secondary Index 只適合低基數（low cardinality）、低頻查詢的欄位。
  user_id 是高基數（2億種值）+ 高頻（325K reads/sec） → 最差的 Secondary Index 候選。
```

### 跨月查詢的正確處理方式

```javascript
(user_id, bucket) 是複合 key，代表不同月份的資料在不同節點。
「取得最近 50 則推文，跨越 1-2 月」的做法：

  // 在應用層並行發出多個查詢
  query_feb = SELECT FROM tweets WHERE user_id=123 AND bucket='2025-02' LIMIT 20
  query_jan = SELECT FROM tweets WHERE user_id=123 AND bucket='2025-01' LIMIT 30

  // 兩個查詢同時執行（parallel，非 sequential）
  results = await Promise.all([query_feb, query_jan])

  // 應用層合併並重新排序
  merged = merge_and_sort(results)
  return merged[:20]

關鍵：應用層需要知道要查哪幾個 bucket（通常就是最近 1-2 個月）。
並行發出，合併結果 → 效能依然快。
```

### Cassandra 做不到的查詢（不要嘗試）

```sql
-- ❌ 全文搜尋：必須全節點掃描
SELECT * FROM tweets WHERE user_id = 123 AND content LIKE '%hello%'

-- ❌ 跨用戶聚合：沒有全局索引
SELECT COUNT(*) FROM tweets WHERE created_at > '2025-01-01'

-- ❌ 不帶 Partition Key 的查詢：Cassandra 直接拒絕
SELECT * FROM tweets WHERE bucket = '2025-02'
```

這些查詢要用 **Elasticsearch**（全文搜尋）或 **Analytics DB / Data Warehouse**（聚合分析）處理，而非 Cassandra。

---

## 3. Adaptive Bucketing（自適應分桶）— 進階

固定月份 bucket 對超高頻發文用戶（如新聞帳號、機器人）仍可能造成單一 partition 過大。解法是根據用戶發文量動態調整 bucket 粒度：

```javascript
發文量               bucket 策略     範例
───────────────────────────────────────────────────
< 100 則/月          年   (YYYY)     '2025'
100 ~ 1,000 則/月    月   (YYYY-MM)  '2025-02'
1,000 ~ 5,000 則/月  週   (YYYY-Www) '2025-W08'
> 5,000 則/月        日   (YYYY-MM-DD) '2025-02-23'
```

實作上，User Service 追蹤每個用戶的發文量級別，Tweet Service 在寫入時查詢該用戶的 bucket 策略，選擇適當粒度。代價是應用層需要知道每個用戶用哪種 bucket，查詢時稍微複雜。

---

## 4. 一表對一查詢模式（刻意反正規化）

Cassandra 的黃金法則：**一個查詢模式對應一張表**，不同查詢模式就建不同的表，用空間換時間。

```sql
-- 表 A：依用戶查詢推文（時間軸、個人頁）
CREATE TABLE tweets_by_user (
  PRIMARY KEY ((user_id, bucket), tweet_id)
);

-- 表 B：依 tweet_id 查詢推文內容（點開單則推文、hydrate）
CREATE TABLE tweet_objects (
  PRIMARY KEY (tweet_id)
);

-- 寫入時同時寫兩張表（應用層負責）
-- 讀取時根據查詢模式選擇對應的表
```

```javascript
Timeline 讀取流程：
  Step 1: Redis ZREVRANGE timeline:{uid}  → 取得 20 個 tweet_id
  Step 2: tweet_objects WHERE tweet_id IN [...]  → 取得推文內容
  
  tweets_by_user 用於：快取 miss 時重建 timeline（批量取某用戶的推文 ID）
  tweet_objects  用於：hydrate 單則推文內容
```

這不是資料冗餘，是刻意的**反正規化（Denormalization）**— Cassandra 系統設計的標準做法。

---

## 5. 分片帶來的問題

**跨分片 JOIN 幾乎不可能**：兩張表的資料分散在不同節點，JOIN 需在應用層手動組裝，效能差且複雜。

**跨分片事務困難**：無法用單一 ACID 事務跨越多個 Shard，需使用分散式事務（Two-Phase Commit）或最終一致性設計。

**資料再平衡 (Rebalancing)**：節點增減時需搬移資料，期間若無 Consistent Hashing，幾乎所有 key 的路由都會改變。Consistent Hashing 將搬移量控制在最小範圍。

**熱點分片 (Hot Shard)**：特定 key（如名人帳號）集中大量讀寫，即使整體叢集不忙，該節點也可能過載。解法：複合 Partition Key + Bucket 分散，或應用層的讀取快取。

**路由複雜度**：應用層需維護「這個 key 該去哪個 Shard」的路由邏輯，或依賴 Coordinator Node 自動處理。

---

## 6. SQL vs. NoSQL 的分片差異

**SQL（如 MySQL）**：通常需要手動分片 (Application-Level Sharding)。開發者需在程式碼中維護路由邏輯。跨分片 JOIN 幾乎不可能，需依賴應用層組裝。

**NoSQL（如 Cassandra, DynamoDB）**：內建自動分片與一致性雜湊。資料庫層自動處理分佈與節點擴充，適合需要極致寫入效能與分散式容錯的海量系統。**但必須在建 schema 時就根據查詢模式設計 Partition Key**，之後很難改變。

---

## 7. 分片與 ID 生成的「路由死結」與現代解法

**傳統死結**：

```javascript
Web Server 必須先有 ID → 才能算 Hash(ID) % N → 決定寫入哪個 Shard
但如果依賴 DB Auto-increment → 連線前沒有 ID → 無法算路由
```

**解法一：NoSQL Client-Side ID + 智慧路由**

NoSQL Driver 在記憶體中直接生成全域唯一 ID，無需詢問 DB：

- **MongoDB ObjectID（12 bytes）**
```javascript
[ 4 bytes Unix 時間戳（秒） ][ 5 bytes 隨機值 ][ 3 bytes 遞增碼 ]
```
精度為秒級，跨機器在同一秒內的排序不保證嚴格正確。
- **Snowflake ID（Twitter，64-bit）**
```javascript
[ 41-bit 毫秒時間戳 ][ 10-bit 機器 ID ][ 12-bit 序列號 ]
```
毫秒精度、全域排序保證、8 bytes（比 ObjectID 小 33%）、純記憶體生成約 1 微秒。Worker ID 在啟動時由 ZooKeeper 分配一次，執行期間完全不需協調。

生成 ID 後，Web Server 連到叢集任意節點（Coordinator），Coordinator 用一致性雜湊自動轉發，應用層零路由邏輯。

**解法二：現代 SQL 生態**

- **分片中介軟體**（Vitess、Apache ShardingSphere）：在 Web Server 與 MySQL 叢集之間加 Proxy，Proxy 內建 Snowflake ID 生成器與路由表，Web Server 以為在操作一台巨型 MySQL。
- **原生分散式 SQL / NewSQL**（TiDB、CockroachDB、Google Spanner）：底層是 NoSQL 式自動分片，上層保持完整 SQL + ACID。CockroachDB 建議用 UUID；TiDB 提供 `AUTO_RANDOM` 屬性，自動帶隨機前綴避免寫入熱點。

---

## 8. Twitter 實際分片設計小結

```javascript
資料層         分片策略                   原因
───────────────────────────────────────────────────────
推文           Cassandra                  高寫入、時序查詢
               PRIMARY KEY ((user_id, bucket), tweet_id)
               bucket = 'YYYY-MM'
社交圖譜       Cassandra                  大量扇出讀取
               follows_by_follower 表
               follows_by_followee 表（反向查詢用）
用戶資料       PostgreSQL（單機 + 讀副本）低寫入、需 ACID
               Snowflake BIGINT PK
時間軸快取     Redis Cluster              毫秒讀取
               ZADD timeline:{user_id}    Sorted Set by timestamp
全文搜尋       Elasticsearch              倒排索引，非主要儲存
               按 tweet_id 範圍分片
```

**核心原則**：Partition Key 必須與最常見的查詢模式一致。不同查詢模式 → 不同的表 → 不同的 Partition Key（以空間換時間的刻意反正規化）。

> **面試提示**：被問到分片時，先說「先確認查詢模式是什麼」，再根據查詢模式選 Partition Key。這個順序展示你理解 Cassandra 的設計哲學，而不只是背公式。