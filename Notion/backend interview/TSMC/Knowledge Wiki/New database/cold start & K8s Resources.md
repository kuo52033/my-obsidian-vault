---
notion-id: 2e95a6e2-1812-8028-8ac8-c11778773509
base: "[[New database.base]]"
多選:
  - K8S
狀態: 完成
---
## Cold start

- **定義：**當一個 Serverless 函數在「閒置許久」或「第一次」被觸發時，雲端平台需要時間來準備執行環境，這段額外的等待時間就叫冷啟動 。
- **發生過程 (Under the hood)：**
當請求進來，平台發現沒有現成的實例 (Instance) 可用，它必須依序做以下動作：
    1. **下載程式碼 (Download Code):** 從 S3 或儲存庫拉取你的程式碼或容器映像檔。
    2. **啟動容器/環境 (Start Container):** 啟動一個新的執行環境。
    3. **初始化 Runtime (Init Runtime):** 啟動語言環境 (如 Node.js process, Python interpreter)。
    4. **執行你的初始化代碼 (User Init):** 執行 Global 變數、建立 DB 連線等。
    5. **執行處理函式 (Handler):** 這時候才真正開始處理請求。
    - *上述 1~4 的時間總和就是 Cold Start Latency。*

## k8s limit and request

這是 **Kubernetes (K8s)** Pod 設定檔 (`yaml`) 中 `resources` 的兩個關鍵參數，用來管理 CPU 和 Memory 。

### A. Request (請求/保證值) —— 給「排程器 (Scheduler)」看的

- **定義：** 容器啟動時，**保證**一定要拿到的最低資源量。
- **用途：** K8s Scheduler 在決定要把 Pod 丟到哪一台 Node (機器) 上時，是看 Request。
    - 如果某台 Node 的剩餘 CPU < Pod 的 CPU Request，Scheduler 就不會把 Pod 排過去。

### B. Limit (限制/上限值) —— 給「容器執行環境 (Runtime)」看的

- **定義：** 容器運作時，**被允許使用**的最大資源上限。
- **用途：** 防止單一 Pod 吃光整台機器的資源，影響到鄰居。
- **超過時的行為（非常重要，必考！）：**
    - **CPU 超過 Limit：** **降速 (Throttling)**。K8s 透過 Linux Cgroups 限制 CPU 時間片，程式會變慢，但**不會被殺掉**。
    - **Memory 超過 Limit：** **OOMKilled (Out of Memory)**。程式會直接崩潰重啟，這就是您在 HPA 案例中遇到的「Server 重啟」的主因。