為什麼需要 BullMQ？

> 用戶傳了一個問題，系統需要呼叫 OpenAI 產生回覆。 OpenAI 可能要等 3-10 秒才回來。
> 
> 如果直接在 WebSocket handler 裡等，這 3-10 秒 Server 就卡在那裡。

這就是為什麼需要 **async job queue**：

> **把耗時的工作丟進 queue，讓 worker 在背景處理，主流程繼續跑。**

---
### 核心概念

| 角色       | 說明                   |
| -------- | -------------------- |
| Producer | 把 job 丟進 queue       |
| Queue    | 儲存待處理的 job（存在 Redis） |
| Worker   | 從 queue 拿 job 來處理    |

---

### Job 的生命週期
```
waiting
   ↓
active  ← Worker 拿走，開始處理
   ↓
┌──┴───────────┐
completed   failed (retry)
```

---
### 重要設定

Retry
``` js
await queue.add('generate', data, {
  attempts: 3,          // 最多重試 3 次
  backoff: {
    type: 'exponential',
    delay: 1000         // 1s, 2s, 4s
  }
})
```

Delay
```js
// 5 秒後才開始處理
await queue.add('generate', data, {
  delay: 5000
})
```

Concurrency
```js
// 這個 Worker 同時最多處理 5 個 job 
const worker = new Worker('ai-reply', processor, { concurrency: 5, connection })
```

---
### 底層結構 ([[Redis Stream & Redis List|Redis Stream]])

|BullMQ 概念|Redis Streams 概念|
|---|---|
|Queue|Stream|
|Job|Stream 裡的一筆訊息|
|Worker|Consumer Group 裡的 Consumer|
|Job 完成 ACK|XACK|
|Job ID|Stream 訊息 ID|

```bash
bull:{queue-name}           ← Stream，存 waiting 的 job
bull:{queue-name}:active    ← 正在處理的 job
bull:{queue-name}:completed ← 完成的 job
bull:{queue-name}:failed    ← 失敗的 job
bull:{queue-name}:delayed   ← 等待延遲的 job
```

```js
const worker = new Worker('ai-reply', processor, { concurrency: 5, connection })

代表建立一個專門取得 ai-reply stream 的 consumer group，並且建立一個 worker，這個 worker 一次取出5個 job，同時處理

Consumer Group: bull:ai-reply 
├── Worker 1 (concurrency: 3) ── 同時處理 job1, job2, job3 
├── Worker 2 (concurrency: 3) ── 同時處理 job4, job5, job6 
└── Worker 3 (concurrency: 3) ── 同時處理 job7, job8, job9

總吞吐量 = Worker 數量 × concurrency。
```