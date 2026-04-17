---
notion-id: 3385a6e2-1812-803d-9cc1-d86b8cf80bc7
base: "[[New database.base]]"
多選: []
狀態: 完成
---
AWS 自己開發的雲端原生資料庫，相容 MySQL / PostgreSQL，但架構跟傳統 RDS 完全不同。

---

**傳統 MySQL Master-Slave：**

```javascript
Master                    Slave
┌─────────────┐           ┌─────────────┐
│  DB Engine  │           │  DB Engine  │
├─────────────┤           ├─────────────┤
│   Storage   │──binlog──→│   Storage   │
│  （自己的）   │  複製資料  │  （自己的）   │
└─────────────┘           └─────────────┘
```

每個節點有自己獨立的 Storage，資料要複製一份過去，所以有 replication lag。

---

**Aurora 共享 Storage：**

```javascript
Compute 層（你管的）
┌──────────┐   ┌──────────┐  ┌──────────┐
│  Writer  │   │ Reader 1 │  │ Reader 2 │
│  AZ-A    │   │  AZ-B    │  │  AZ-C    │
└────┬─────┘   └────┬─────┘  └────┬─────┘
     │              │              │
     └──────────────┴──────────────┘
                    │
Storage 層（Aurora 自動管）
┌───────────────────────────────────┐
│         共享 Storage Layer         │
│   AZ-A      AZ-B        AZ-C      │
│  [v1][v2]  [v1][v2]   [v1][v2]   │
│         6 份副本                   │
└───────────────────────────────────┘
```

Writer 寫進共享 Storage，Reader 直接從同一個 Storage 讀，**不需要複製資料**。

所以 Reader 的延遲極低，因為本質上讀的是同一份資料。

**6 份副本的意義：**

```javascript
寫入時：至少 4 份確認寫成功才回應 client
讀取時：至少 3 份確認才回應

容錯能力：
  失去 2 個 node → 還能寫入 ✅
  失去 3 個 node → 還能讀取 ✅
```

### 跟傳統 RDS（Master-Slave）的差異

|   | 傳統 RDS | Aurora |
| --- | --- | --- |
| Storage | 每個節點獨立 | 所有節點共享 |
| 資料複製 | binlog 複製 | 不需要複製 |
| Replication Lag | 幾秒 ~ 幾十秒 | 通常 < 100ms |
| Failover 時間 | 1~2 分鐘 | 通常 < 30 秒 |
| Read Replica 上限 | 5 個 | 15 個 |
| Storage 上限 | 需要預先設定 | 自動擴展到 128TB |

---

### Compute 層：要自己管的事

**Reader 分散到不同 AZ（要自己設定）：**

```javascript
Writer  → AZ-A
Reader1 → AZ-B  ← 自己指定
Reader2 → AZ-C  ← 自己指定
```

如果 Reader 都在同一個 AZ，Writer 掛掉又剛好在同一個 AZ，就沒有可用的 Reader 可以提升。

**Failover Priority（要自己設定）：**

```javascript
Reader1 → Priority 0  ← Writer 掛掉優先提升這個
Reader2 → Priority 1  ← 備用

Priority 0 最高，15 最低
```

---

### 兩個 Endpoint

```javascript
Writer endpoint：永遠指向當前的 Writer
  → 寫入、需要即時一致性的查詢

Reader endpoint：負載均衡到所有 Reader
  → 報表查詢、統計、一般讀取
```

應用層要自己決定哪些查詢走哪個 endpoint，Aurora 不知道你的 SQL 是讀還是寫：

javascript

```javascript
const writer = mysql.createPool({ host: WRITER_ENDPOINT })
const reader = mysql.createPool({ host: READER_ENDPOINT })

await writer.query('INSERT INTO ...')
await reader.query('SELECT ...')
```

---

### 

### 什麼是自動的，什麼要自己設定

```javascript
自動（不需要設定）：
  ✅ Storage 6 份副本跨 AZ
  ✅ Writer 掛掉自動 Failover
  ✅ Storage 自動擴展
  ✅ 自動備份到 S3

要自己設定：
  ⚙️ Reader 數量和放哪個 AZ
  ⚙️ Failover Priority
  ⚙️ 應用層讀寫分離邏輯
  ⚙️ Instance 大小
  ⚙️ Slow query log 和 CloudWatch 告警
```