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
active        ← Worker 拿走，開始處理
   ↓
┌──┴───────────┐
completed   failed (retry)
```
