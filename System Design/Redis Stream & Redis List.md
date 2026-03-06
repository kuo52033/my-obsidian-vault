---
aliases:
  - Redis Stream
---

### Redis List
最簡單的資料結構，就是一個 [[Double Link List]]
```bash
HEAD                                TAIL
 ↓                                   ↓
[A] ←──→ [B] ←──→ [C] ←──→ [D] ←──→ [E]
```
用 List 做 job queue 產生的問題

1. job 消失
	1. worker BRPOP 拿走 Job, 處理到一半 crash, Job 消失，永遠不會被處理
2. 沒有 ACK
	1. 沒有辦法確認 Job 是否真的有處理成功
3. 難以監控
	1.  Job 被 pop 走就消失了，無法查詢「目前有哪些 Job 正在處理」

### Redis Stream
> [!INFO] Streams 是 Redis 5.0 加入的資料結構，專門為訊息佇列設計。 本質是一個**append-only log**，訊息只會往後加，不會消失。

```bash
Stream: my-stream 
┌──────────────┬─────────────────────────┐ 
│ ID           │ Data                    │ ├──────────────┼─────────────────────────┤  
│ 1700000001-0 │ { type: 'msg', ... }    │ 
│ 1700000002-0 │ { type: 'msg', ... }    │ 
│ 1700000003-0 │ { type: 'msg', ... }    │ └──────────────┴─────────────────────────┘ 
      ↑ timestamp-sequence
      
# 寫入訊息（* 表示自動產生 ID） 
XADD my-stream * type msg text hello 
# 讀取（從頭開始） 
XRANGE my-stream 0 + 
# 讀取（從某個 ID 之後） 
XRANGE my-stream 1700000002-0 + 
# 讀取最新的 N 筆 
XREVRANGE my-stream + - COUNT 10
```
### Consumer Group 

> [!TIP] 單純讀 Stream，所有人都看到一樣的東西。 Consumer Group 讓你做到**競爭消費**

```bash
Stream 
  ↓ 
Consumer Group: workers 
├── Consumer 1 ── 拿走 job1 
├── Consumer 2 ── 拿走 job2 
└── Consumer 3 ── 拿走 job3

# 建立 Consumer Group
XGROUP CREATE my-stream workers 0 
# Consumer 1 來拿 job（> 表示拿還沒被這個 group 處理的） 
XREADGROUP GROUP workers consumer1 COUNT 1 STREAMS my-stream > 
# 處理完，發 ACK 
XACK my-stream workers 1700000001-0

Redis 內部維護每個 Group 的 last-delivered-id：，每次派發後，last-delivered-id 往後移，所以不會重複派給同一個 Group 裡的不同 Worker。
```

> [!NOTE] **不同 Group 之間，每個 job 都會被各自收到，不競爭。 同一個 Group 內，每個 job 只會給一個 Worker，互相競爭。**

```bash
Stream: my-stream 
┌──────┬──────┬──────┐ 
│ job1 │ job2 │ job3 │ 
└──────┴──────┴──────┘ 
Group A last-delivered-id: 0 
Group B last-delivered-id: 0 
Group A 讀取 → 拿到 job1, job2, job3 
Group B 讀取 → 也拿到 job1, job2, job3 ← 各自獨立，互不影響
```

| 情況                  | 行為                    |
| ------------------- | --------------------- |
| 同一個 Group，多個 Worker | 競爭消費，job 只給一個人        |
| 不同 Group            | 各自獨立，job 每個 Group 都收到 |
