為什麼需要 BullMQ？

> 用戶傳了一個問題，系統需要呼叫 OpenAI 產生回覆。 OpenAI 可能要等 3-10 秒才回來。
> 
> 如果直接在 WebSocket handler 裡等，這 3-10 秒 Server 就卡在那裡。

這就是為什麼需要 **async job queue**：

> **把耗時的工作丟進 queue，讓 worker 在背景處理，主流程繼續跑。**