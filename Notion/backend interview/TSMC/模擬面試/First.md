---
notion-id: 3385a6e2-1812-8093-8196-e10905dddddf
---
## 0. 面試設定與核心評估點

- 目標職能：**服務擴充性、效能優化、可靠性、K8s/EKS 思維、系統設計**
- 面試官常看：
    - 是否能用**證據鏈**定位問題（log/metric/event）
    - 是否能講清楚**trade-off**（穩定性 vs 成本、延遲 vs 正確性）
    - 是否懂**分層設計**（ingestion / streaming / storage / query / reliability）

---

## 1. 代表性專案（主故事線）

### 專案：財務系統（data-intensive）

你主講內容：

- 你負責：**後端架構規劃、DB、i18n（多國語系）設計**
- 情境：資料成長快、需提供給多個第三方串接
- 痛點：**匯出報表 OOM** → 影響後台 API 可用性
- 解法：
    - **拆成獨立服務**跑匯出（降低 blast radius）
    - **排程**控制同時匯出量（避免尖峰堆爆）
    - DB 取資料：**keyset pagination**
    - 匯出：**stream**（避免一次 buffer 進記憶體）
    - 後台服務：依 CPU **自動擴充 1~3 pods**

---

## 2. 效能/可靠性深挖 Q&A（你已回答＋面試官期待點）

### Q1 你怎麼確認是 OOM？

你的證據鏈（✅很對）：

- Pod 反覆重啟 → k8s log/event 出現 **OOMKilled / out of memory**
- Grafana memory 監控在匯出期間 **尖峰飆高**
**可背版本：**
- 「pod restart → OOM log/event → Grafana memory spike 交叉驗證」

---

### Q2 你怎麼鎖定根因是報表匯出？

你做的事（✅方向正確）：

- 用 ELK 排序觀察：哪些 API response time 異常、集中在出問題時段
- 對照後台匯出操作紀錄 + SQL 測試資料量巨大
**加分補一句：**
- 「因此判斷是一次性載入造成 memory 暴衝，而非長期 memory leak」

---

### Q3 為什麼選「拆服務 + 排程 + pagination + stream」？

你核心理由（✅成熟）：

- 拆服務：避免匯出拖垮後台（**隔離/降低影響範圍**）
- 排程：限制同時匯出數量（**節流/整形**）
- pagination + stream：改變記憶體模型（**從 O(n) → O(1)/固定 chunk**）
**面試官愛聽關鍵字：** blast radius、backpressure、SLO/可用性

---

### Q4 併發與一致性：多 worker 怎麼避免重複匯出？

你的做法（✅正確路線）：

- DB 狀態機：PENDING / PROCESSING / DONE
- Claim 任務用**原子條件更新**：`UPDATE ... WHERE status='PENDING'`
- 以 affected rows 判斷只有一台成功
**面試安全版：**
- 「條件式 UPDATE 原子 claim，失敗者 affected rows=0 直接退出」

---

### Q5 stuck job（卡 PROCESSING）怎麼辦？

你的做法（✅可行、業界常見）：

- watchdog/reaper 排程掃描超時 PROCESSING → reset 回 PENDING
- **一定要搭配 idempotency**，避免重跑產生兩份結果

---

### Q6 Pagination：offset vs keyset

你回答（✅很加分）：

- 用 **keyset pagination**：記錄 last_id → `WHERE id > last_id LIMIT N`
- 避免大 offset 掃描效率差

**延伸：排序不是 id 時怎麼辦（你補得更完整的版本）**

- 若依 createdAt 排序：用複合 cursor **(createdAt, id)**
- 建 secondary / composite index：`(createdAt, id)`
- cursor 條件：`createdAt > lastCreatedAt OR (createdAt=lastCreatedAt AND id>lastId)`
→ 保證不漏、不重複

---

### Q7 stream 的本質（你比喻很好）

你答案（✅）：「像漏斗 chunk 處理」

**面試精準版：**

- 「一次載入全部 → 逐段讀取/處理/輸出，記憶體與 chunk size 綁定，並可形成 backpressure」

---

### Q8 大量 join 怎麼取捨（正確回答框架）

**推薦面試答案（可背）**

- **預設 DB join 再 stream**：DB 最擅長 join / planner / index，減少 round trip
- 若 join 複雜/負載過高影響 DB 穩定性 → 才拆查詢到應用層組裝（chunk/stream），並用指標（DB latency/CPU/IO）決策

---

## 3. K8s / EKS 主題（noisy neighbor、擴充、成本）

### noisy neighbor 是什麼？

- 同 node 多 workload 資源競爭 → **延遲飆高 / throttling / OOMKilled**
- 根因不是 scheduler bug，而是**overcommit + 隔離不足**

### overcommit（重要觀念）

- scheduler 主要看 **requests** 排程
- requests 設太低 → 排太滿 → runtime 使用量暴增就互相擠壓
- **CPU 可壓縮**（變慢）、**Memory 不可壓縮**（超過就 OOM）

### 解法分層（你走得很好）

1. **第一層：調整 requests（最低成本、最快見效）**
2. **第二層：node group 隔離**（不同專案/性質分 node group）
    - 用 node labels + selector/affinity 排到指定 node group
3. Namespace vs node group（你回答正確）
    - namespace：邏輯/管理隔離（RBAC/quota/network policy），**不決定排到哪個 node**
    - node group：實體資源隔離，**直接影響排程與 noisy neighbor**

### 成本取捨（你回答正確）

- production/關鍵：隔離優先（專案各自 node group）
- staging/非關鍵：共用提高利用率

### Pod scale vs Node scale（要講對）

- Pod：HPA（CPU/自訂 metrics）
- Node：Cluster Autoscaler
    - **不是**看 node CPU 直接加機器
    - 而是看 **有 pending pod 排不下** 才擴 node group

### memory-based HPA（你理解到位）

- 不是不能用，但**門檻不要貼近 OOM**，避免反應不及造成震盪
- 更穩：用 backlog/queue length/request rate 等「壓力前兆」+ custom metrics

---

## 4. 白板系統設計（全新題：Telemetry 平台）

### 需求假設（你設定）

- 寫入：1000 QPS
- 查詢：單設備時間窗 + 跨設備聚合
- 告警：秒級

### 建議主幹架構（分層你抓得很好）

- Ingestion（HTTP/gRPC）
- Kafka（事件中樞：解耦/緩衝/可重播）
- Stream Processing（秒級告警：stateful window）
- TSDB/OLAP（近即時查詢 + 聚合）
- S3 cold storage（30 天後 raw/降採樣長期保存）
- Downsample job（寫 aggregated 結果）

### Kafka → Stream Processing / Kafka → Storage 是不是同原理？

- ✅都是 **不同 consumer groups** 消費同 topic
    - group A：告警（stateful）
    - group B：寫入 DB（append/stateless）

### Kafka 併行上限（你被糾正後已理解）

- **最大並行度 = partition 數**
- 10 partitions / 5 consumers → 平均每人約 2 partitions
- consumers > partitions → 多的會 idle

### Hot partition / data skew（你答到熱點，但解法要修）

- 問題：`deviceId` 固定落某 partition → **那個 partition 成 bottleneck**
- 不能只靠加 consumer（同 partition 同時只能給一個 consumer）
- 常見解法：
    - 增 partitions（必要不充分）
    - `deviceId + shard`（時間桶/固定 shard）分散熱點（trade-off：亂序）
    - 拆 topic（high-rate vs normal）隔離風險

### 告警遇到亂序：event time / watermark（你答對核心）

- 用 **event time**（事件發生時間）而非 processing time
- window + watermark/allowed lateness（例如允許晚到 10 秒）
- 定義 late data 策略（補發修正 or 記錄不影響告警）

### 不丟資料：at-least-once + idempotency（你方向正確）

- consumer：**處理成功寫入下游後才 commit offset** → at-least-once
- DB：用 **idempotency key / unique constraint / upsert** 去重

### Kafka 掛掉 5 分鐘（你回答需轉向「退化設計」）

面試官期待你先講：

- 退化：寫入/告警延遲、查詢仍可用但資料不新
- 不丟：Ingestion 端 **buffer/spool** + backpressure（這不是 Kafka 原生）
- 恢復：Kafka 回來後 consumer 依 offset catch up、觀察 lag，必要時擴資源加速

---

## 5. MQTT broker vs Kafka broker vs Redis Pub/Sub（定位差異）

- **MQTT broker**：IoT 裝置通訊協議，QoS/輕量連線，偏設備端
- **Kafka broker**：事件串流平台，持久化 + replay + consumer group + 高吞吐
- **Redis Pub/Sub**：即時廣播（通常不持久化、不支援 replay），subscriber 掛掉訊息就不見

你總結（✅很對）：

- telemetry 主幹選 Kafka：**可回溯、可重播、consumer 掛掉不丟（靠 offset）**
- Redis pub/sub 不適合「可靠 + 可回溯」的主幹

---

## 6. 你本次面試表現總評（第一輪）

### 優點

- 問題定位有證據鏈（log + metric + 行為）
- keyset pagination / stream / 原子 update claim 任務：很工程實務
- K8s 概念完整（requests、隔離、HPA vs CA）
- 白板分層清楚、能承認沒做過但給出合理設計（成熟）

### 容易被追問的點（下次要準備）

- 數據化：OOM 前後記憶體/耗時改善幅度、匯出量級、P95 latency
- DB 索引/partition 的具體設計（表結構、索引、查詢範式）
- 故障情境：Kafka down、DB slow、stream lag 的退化與恢復策略

---

## 7. 行動清單（下一次模擬前）

- 準備 3 個數字（可背）：
    1. 報表匯出資料量級（rows / 檔案大小 / 平均耗時）
    2. OOM 前後 memory 峰值或 pod restart 次數改善
    3. 匯出 pipeline throughput（每分鐘處理幾份）
- 準備 60 秒版本口條（可背）：
    - 「痛點 → 證據 → 根因 → 解法 → 成效 → 風險控制（idempotency/rollback）」
- 白板題再練一題不同類型（例如：權限/審計系統 or 內部工單系統）