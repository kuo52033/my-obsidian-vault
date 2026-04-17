---
notion-id: 3395a6e2-1812-8077-98b4-d20d24ecf63c
base: "[[New database.base]]"
多選: []
狀態: 完成
---
```javascript
每次請求都打 DB：
  DB 要做磁碟 I/O、執行 SQL、回傳資料
  延遲通常 10ms ~ 幾百ms

加了 Cache：
  資料在記憶體，直接讀
  延遲通常 < 1ms

10倍 ~ 100倍 的速度差異

Hit Rate = Cache Hit 次數 / 總請求次數

Hit Rate 越高越好
80% 以上才算有效果
如果 Hit Rate 很低，加 Cache 反而增加複雜度沒有收益
```

![[截圖_2026-04-05_下午3.04.46.png]]

---

- Cache-aside

```javascript
read-heavy workloads
應用層自己管 Cache

讀：
  查 Cache → Hit 直接回傳
           → Miss 查 DB → 寫進 Cache → 回傳

寫：
  寫入 DB → 讓 Cache 失效（delete）
  下次讀的時候再從 DB 載入
```

優點：Cache 掛掉不影響系統，只是變慢

缺點：第一次永遠 Miss，可能有短暫的資料不一致

---

- Write-Through

```javascript
寫入時同時寫 DB 和 Cache

寫：
  同時寫 DB 和 Cache
  兩個都成功才算完成

讀：
  查 Cache → 幾乎永遠 Hit（因為寫入時就存了）
```

優點：Cache 永遠是最新的，不會有不一致
缺點：寫入延遲增加（要等兩個都完成）、Cache 存了很多不會被讀的資料

---

- Read-Through

```javascript
Cache 自己去 DB 載入資料
應用層只跟 Cache 互動，不直接打 DB

讀：
  查 Cache → Hit 直接回傳
           → Miss Cache 自己去 DB 載入，再回傳
```

跟 Cache-Aside 類似，差別是載入 DB 的邏輯在 Cache 層，不在應用層。

---

- Cache TTL

```javascript
資料變動頻率高（訂單狀態）→ TTL 設短，30~60 秒
資料變動頻率低（商品資訊）→ TTL 設長，幾小時甚至幾天
資料幾乎不變（匯率基準）  → TTL 設很長，搭配手動失效
```

---

- Cache Stampede (快取踩踏）

```javascript
熱點資料 Cache 過期的瞬間
大量請求同時 Miss
同時去 DB 查同一筆資料
DB 瞬間壓力暴增
```

解法：互斥鎖（mutex lock)

```javascript
  // 搶鎖，只有一個請求去打 DB
  const lock = await redis.set(`lock:${key}`, '1', 'NX', 'EX', 5) 
```

---

- Cache layer

```javascript
L1：應用層記憶體（最快，但只在單一 instance）
    → Node.js 的 Map 或 LRU Cache
    → 重啟就消失，不能跨 instance 共享

L2：分散式 Cache（Redis）
    → 所有 instance 共享
    → 重啟資料還在
    → 稍慢但還是比 DB 快很多

L3：DB（最慢，但持久）
```

---

- What data prefer use cache

```javascript
✅ 適合：
  讀多寫少（商品資訊、用戶設定）
  計算成本高的結果（複雜報表、聚合統計）
  熱點資料（首頁、排行榜）
  Session、Token

❌ 不適合：
  需要強一致性（金融交易餘額）
  寫入頻率跟讀取一樣高（沒有收益）
  資料量極大且存取分散（命中率低）
```