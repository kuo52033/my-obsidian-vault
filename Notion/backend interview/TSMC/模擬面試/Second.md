---
notion-id: 3385a6e2-1812-8085-9e24-e5560367b006
---
# 面試弱項知識補強

---

## 1. Response 路徑 + 架構全局觀

### 你答錯的地方

Response **不走 NAT Gateway**。HTTP 是基於 TCP 的，response 沿著同一條 TCP connection 原路返回：

```plain text
Request:  Client → Cloudflare → NLB → NGINX → Pod
Response: Pod → NGINX → NLB → Cloudflare → Client
```

### NAT Gateway 是什麼時候用的？

當 **Pod 主動發起對外連線** 時才走 NAT Gateway：

- 呼叫第三方 API（支付、簡訊）
- 連外部 SaaS 服務
- npm install（build 階段）
- 連 AWS 服務（如果沒走 VPC Endpoint）

流程：Pod → ClusterIP → Node → NAT Gateway → Internet Gateway → 外部服務

### 記憶口訣

- **進來的流量**：走 NLB（ingress）
- **出去的流量**：走 NAT GW（egress）
- **Response**：不是新流量，是原本那條 TCP connection 的回程

### 架構全局觀 — 面試口述模板

講完同步路徑後，主動帶一段：

> 「以上是同步的 HTTP request 路徑。除此之外，我們的系統還有兩條非同步路徑： 第一是即時通訊 — 走 WebSocket 長連線，多 Pod 之間透過 Redis Pub/Sub 同步訊息。 第二是背景任務 — 耗時操作（AI 回覆、報表產出、DB 寫入）丟進 BullMQ 由獨立 Worker Pod 非同步處理。 資料層的部分，主資料庫是 RDS Aurora MySQL，RAG 向量搜尋用 MongoDB Atlas，報表檔案存 S3。」

---

## 2. 網路層：Cloudflare SSL 模式 + externalTrafficPolicy

### Cloudflare SSL 四種模式

| 模式 | Cloudflare → Origin | 安全性 | 你們目前的狀態 |
| --- | --- | --- | --- |
| **Off** | 不加密 | 最低 | — |
| **Flexible** | HTTP（明文） | 低 | ← 你們是這個 |
| **Full** | HTTPS（不驗證憑證） | 中 | — |
| **Full (Strict)** | HTTPS（驗證憑證） | 最高 | 建議的改善方向 |

### 面試怎麼說

> 「目前我們用的是 Cloudflare Flexible SSL 模式，Cloudflare 到 origin 這段走 HTTP。這是團隊在效能和安全性之間的取捨 — 流量在 Cloudflare 和 AWS 骨幹網路之間傳輸，被攔截的風險相對低。但如果要更嚴謹，可以升級到 Full (Strict) 模式，在 NLB 上掛 ACM 憑證做二次 TLS。NLB 支援 TLS listener，可以把 ACM 憑證綁上去，解密後再轉發給 NGINX。」

### externalTrafficPolicy: Local vs Cluster

```plain text
                        Cluster (預設)              Local
流量路徑                 NLB → 任意 Node → Pod      NLB → Pod 所在 Node → Pod
跨 Node 轉發             會                         不會
Client IP 保留           不保留（被 SNAT 覆蓋）      保留
流量分配                 均勻                        可能不均勻（取決於 Pod 分佈）
```

**你們用 Local 的原因：**

1. 金融系統需要取得真實 Client IP 做 rate limiting 和 IP blacklist
2. 減少一跳（少一次跨 node 轉發），降低延遲

**Local 的風險：** 如果某個 node 上有 3 個 Pod，另一個 node 上只有 1 個 Pod，NLB 會平均分配到兩個 node，導致那 1 個 Pod 承受 50% 的流量。解法：用 podAntiAffinity 讓 Pod 盡量均勻分佈。

### 面試怎麼說

> 「我們把 externalTrafficPolicy 設為 Local，主要是為了保留 Client IP。金融系統需要真實 IP 做 rate limiting 和黑名單機制。設成 Cluster 的話，流量跨 node 轉發時會被 SNAT，Client IP 就丟失了。Local 的風險是流量分配可能不均勻，所以我們搭配 podAntiAffinity 讓 NGINX ingress controller 的 replica 分散到不同 node 上。」

---

## 3. K8s 資源管理：CPU Throttle vs OOM Kill + Overcommit

### 核心概念：可壓縮 vs 不可壓縮資源

```plain text
CPU（可壓縮 Compressible）       Memory（不可壓縮 Incompressible）
─────────────────────────       ─────────────────────────────────
超過 limit → 被 Throttle        超過 limit → 被 OOM Kill
（Pod 還活著，只是變慢）          （Pod 直接被殺，container 重啟）

request 是「最低保障」            request 是「最低保障」
可以 burst 到 limit              可以用到 limit
超過 limit 就被節流               超過 limit 就被殺
```

### Request 和 Limit 的作用

```plain text
            ┌─────────────────────────────────────────┐
            │              Node 總資源                  │
            ├──────────┬──────────┬──────────┬─────────┤
 request    │ Pod A    │ Pod B    │ Pod C    │  剩餘   │
 (預約保障)  │ 0.1 CPU  │ 0.1 CPU  │ 0.1 CPU  │ 可排更多│
            ├──────────┴──────────┴──────────┴─────────┤
 limit      │ Pod A: 2 CPU  Pod B: 2 CPU  Pod C: 2 CPU │
 (天花板)    │ ← 如果三個同時 burst = 6 CPU，但 node 只有 4 CPU │
            │ ← 這就是 Overcommit！大家互搶，一起變慢    │
            └─────────────────────────────────────────┘
```

### Overcommit 的風險

- **CPU overcommit**：所有 Pod 同時 burst 時互搶 CPU，大家都被 throttle，延遲升高
- **Memory overcommit**：所有 Pod 同時 burst 時，node 記憶體不夠 → kubelet 觸發 eviction，按 QoS 優先級殺 Pod

### QoS Class（面試加分）

| QoS Class | 條件 | 被 evict 的優先級 |
| --- | --- | --- |
| **Guaranteed** | request = limit（CPU 和 Memory 都是） | 最後被殺 |
| **Burstable** | request < limit | 中間 |
| **BestEffort** | 沒設 request 也沒設 limit | 最先被殺 |

你們的 Redis 沒設 resource limits → **BestEffort** → node 資源不足時第一個被殺。

### 面試怎麼說

> 「request 和 limit 差距大的好處是省成本 — scheduler 依據 request 排 Pod，可以在一個 node 上塞更多 Pod。風險是 overcommit：當多個 Pod 同時 burst 到各自的 limit，node 的實際 CPU 被超賣，大家互搶資源。CPU 超了只是被 throttle，Pod 還活；Memory 超了就 OOM Kill。
> 所以理想的做法是：Memory 的 request 接近 limit（因為超了就死），CPU 可以保留一點 buffer 讓它 burst。設定依據是觀察 Metricbeat 的 P95 用量設 request，最大值加 buffer 設 limit。我們的 Redis 沒設 resource limits，QoS 是 BestEffort，node 資源不足時會第一個被殺，這是待改善的地方。」

---

## 4. Node.js Stream：四種類型 + Backpressure 機制

### 四種 Stream 類型

```plain text
Readable          Transform          Writable
(資料來源)    →    (轉換處理)     →    (資料目的地)
DB cursor         格式化為 CSV row    S3 upload

                  Duplex
                  (雙向讀寫，例如 TCP socket、WebSocket)
```

| 類型 | 說明 | 你的場景中的角色 |
| --- | --- | --- |
| **Readable** | 資料的生產者，可以被讀取 | DB cursor 分批讀取資料 |
| **Transform** | 繼承 Duplex，讀入 → 處理 → 寫出 | 把每筆 DB row 格式化為 CSV row |
| **Writable** | 資料的消費者，接收資料寫入目的地 | S3 multipart upload |
| **Duplex** | 同時可讀可寫（獨立的讀寫通道） | WebSocket 連線（Socket.IO） |

### Backpressure 機制（詳細版）

```plain text
Step 1: Writable 的內部 buffer 滿了
        ↓
Step 2: writable.write(chunk) 回傳 false
        ↓
Step 3: 信號沿 pipeline 往上游傳遞
        ↓
Step 4: Readable 暫停 .read()，不再產出資料
        ↓
Step 5: Writable 慢慢消化 buffer，buffer drain 掉
        ↓
Step 6: Writable 觸發 'drain' 事件
        ↓
Step 7: Readable 恢復 .read()，繼續產出
```

如果**不處理** backpressure（例如用 `readable.on('data', chunk => writable.write(chunk))`）：

- Readable 不管 Writable 的消化速度，一直塞資料
- 資料全部堆在 Writable 的內部 buffer 和 process memory 裡
- 記憶體持續增長 → 最終 OOM

### pipeline() vs pipe()

```javascript
// ❌ pipe() — 錯誤不會自動傳播，可能 memory leak
readable.pipe(transform).pipe(writable);
// 如果 transform 出錯，readable 和 writable 不會被 destroy
// stream 沒被清理 → file descriptor leak、memory leak

// ✅ pipeline() — 任何一段出錯，自動 destroy 所有 stream
const { pipeline } = require('stream');
pipeline(readable, transform, writable, (err) => {
  if (err) console.error('Pipeline failed:', err);
});

// ✅ pipeline() 的 Promise 版本（Node 15+）
const { pipeline } = require('stream/promises');
await pipeline(readable, transform, writable);
```

### 你的 OOM 修復場景完整 Stream 架構

```javascript
const { pipeline } = require('stream/promises');
const { Transform } = require('stream');

// 1. Readable: DB cursor
const dbCursor = createCursorStream(query); // cursor-based pagination

// 2. Transform: row → CSV line
const csvTransform = new Transform({
  objectMode: true,
  transform(row, encoding, callback) {
    const csvLine = formatToCsvRow(row); // 金額格式化、時區轉換等
    callback(null, csvLine + '\n');
  }
});

// 3. Writable: S3 multipart upload
const s3Upload = createS3UploadStream(bucket, key);

// 4. pipeline 串接，自動處理 backpressure + 錯誤清理
await pipeline(dbCursor, csvTransform, s3Upload);
```

### 面試怎麼說

> 「我用了三種 Stream：Readable 從 DB cursor 分批讀取，Transform 把每筆資料格式化為 CSV row，Writable 做 S3 multipart upload。三者用 `stream.pipeline()` 串接。
> pipeline 的好處是自動處理 backpressure — 當 S3 上傳速度跟不上 DB 讀取速度時，Writable 的 write() 回傳 false，信號往上游傳遞，讓 Readable 暫停讀取。等 Writable 的 buffer drain 掉後觸發 drain 事件，上游才恢復。
> 
> 之所以用 pipeline 而不是 pipe，是因為 pipe 的錯誤不會自動傳播。如果中間的 Transform 出錯，上下游的 stream 不會被 destroy，可能造成 memory leak。pipeline 會在任何一段出錯時自動 destroy 所有 stream。」

---

## 快速自測 Checklist

能不能不看筆記回答以下問題？

- [ ] HTTP response 走什麼路徑回去？（不是 NAT GW）
- [ ] NAT Gateway 什麼時候用？（Pod 主動發起對外連線）
- [ ] Cloudflare Full (Strict) 和 Flexible 差在哪？
- [ ] externalTrafficPolicy: Local 為什麼能保留 Client IP？
- [ ] CPU 超過 limit 會怎樣？（Throttle）Memory 超過呢？（OOM Kill）
- [ ] 什麼是 overcommit？為什麼 request 和 limit 差太大會有風險？
- [ ] QoS Guaranteed 的條件是什麼？（request = limit）
- [ ] Node.js Stream 四種類型？你用了哪三種？
- [ ] Backpressure 的觸發信號是什麼？（write() 回傳 false）
- [ ] pipeline() 比 pipe() 好在哪？（自動 destroy + 錯誤傳播）