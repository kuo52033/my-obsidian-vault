---
notion-id: 2e95a6e2-1812-806c-a311-e44c0a86062b
base: "[[New database.base]]"
多選:
  - Scalability
  - Architecture
狀態: 完成
---
### 垂直擴充 (Vertical Scaling)

- **定義：** 升級現有的機器硬體（加 CPU、加 RAM、換更快的 SSD）。
- **優點：** 不需要修改程式架構，管理簡單（因為機器數量不變）。
- **缺點：**
    1. **硬體有上限：** 地球上最強的單台伺服器也有極限 。
    2. **單點故障 (SPOF)：** 這台超級電腦掛了，服務就全掛了。
    3. **成本昂貴：** 硬體規格越高，價格是指數級上升。
- **AWS 對應：** 將 EC2 從 `t3.micro` 升級成 `m5.2xlarge`。

### 水平擴充 (Horizontal Scaling / Scale-out) —— **雲端架構的核心**

- **定義：** 增加機器的「數量」來分擔流量。
- **優點：**
    1. **理論上無上限：** 流量大 10 倍，就加 10 倍的機器 。
    2. **容錯率高：** 一台掛了，還有其他台撐著。
    3. **成本彈性：** 配合 Auto Scaling，沒流量時可以減少機器省錢 。
- **缺點：** 軟體架構必須重新設計，必須是「無狀態」的。
- **AWS 對應：** 使用 Auto Scaling Group，讓 EC2 數量從 1 台變 10 台。

### 有狀態/無狀態

- **什麼是有狀態 (Stateful)？**
    - 使用者的 Session、上傳到一半的檔案、或是計算中的變數，存在 **這台 Web Server 的記憶體或本機磁碟** 中。
    - *後果：* 如果這台 Server 當機，資料就丟了；或者如果 Load Balancer 把下一個請求導到另一台 Server，那台 Server 不認識這個使用者（因為 Session 不在那裡） 。
- **什麼是無狀態 (Stateless)？**
    - Server **不存儲** 任何客戶端狀態資訊。
    - 狀態必須外包存儲到 **共用的資料庫 (DB)**、**快取 (Redis)** 或 **物件儲存 (S3)** 。
    - *後果：* 任何一台 Server 都可以處理任何一個請求。Server 變成「免洗筷」，隨時可以增加、刪除、重啟，都不影響服務。

注意：[Socket.io](http://socket.io/) 需要 Sticky Session 配合，且擴充需依賴 Redis Adapter。

## Real-world Practice (STAR)

- situation: 某天發現系統的 API 回應延遲上升，P99延遲到了10秒，導致用戶體驗不好，甚至發生OOM讓server重啟。
- task: 目標是要防止單點的資源瓶頸，確保系統能根據流量自動水平擴充，防止pod因為資源耗盡而重啟
- action: 首先是調整了容易的 CPU 和 memory 的容量，然後設置 HPA，觸發門檻為 CPU 達到70%時會自動擴充
- result: 後來 API 99 穩定維持在1秒以內，也沒有再發生過 OOM 重起事件

