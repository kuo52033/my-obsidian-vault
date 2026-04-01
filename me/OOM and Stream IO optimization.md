### Situation

公司的金融管理系統有一個排程報表功能，會在固定時間從 MySQL 撈取交易資料、產出 CSV 報表並上傳至 S3。某天收到告警，發現報表排程的 Pod 直接被 OOM Kill。透過 OpenSearch 查 log 確認，當資料量達到**約 50 萬筆**時，Pod 的記憶體使用量飆升到數 GB 後被 Kubernetes 強制終止。

### Task
接到 bug report 後，由我負責排查 root cause 並修復。目標是讓報表功能即使面對大量資料也能穩定執行，不再 OOM。

### Action

**1. Root Cause 定位**

- 使用 `node --inspect` 連接 Chrome DevTools 觀測記憶體分配，確認瓶頸在兩個地方：
    - **讀取端**：一次 query 把 50 萬筆資料全部撈進 memory
    - **寫入端**：將全部資料一次寫入 CSV buffer，再整包上傳 S3
- 使用 process.memoryUsage() 
```js
{ rss: 45678592, // Resident Set Size，整個 process 佔用的實體記憶體 
heapTotal: 20971520, // V8 heap 總共分配了多少 
heapUsed: 15234567, // V8 heap 實際用了多少（你的 JS 物件在這） 
external: 1234567, // C++ 物件佔用的記憶體（Buffer 等） arrayBuffers: 123456 // ArrayBuffer / SharedArrayBuffer }
```

**2. 讀取端改造 — Cursor-based Pagination**

- 將原本的單次全量查詢改為 cursor-based pagination，每次只撈取一個批次（例如數千筆）
- 以主鍵作為 cursor，確保分頁查詢效能穩定（避免 OFFSET 在大資料量下的效能退化）

**3. 寫入端改造 — Stream Pipeline**

- 建立 Stream pipeline：DB cursor read → Transform（格式化為 CSV row）→ WriteStream → S3 Upload
- 使用 Node.js 的 `stream.pipeline()` 串接，確保 backpressure 正確處理，避免某一端速度不匹配導致記憶體堆積
- S3 上傳改用 multipart upload，搭配 stream 邊產出邊上傳，不需要在本地暫存完整檔案

**4. 全面推廣**

- 修復驗證完成後，將相同的 Stream 模式套用到系統中所有其他匯出功能，統一改造

### Result

- 透過 `node --inspect` 實測，記憶體用量從**數 GB 降至 100MB 以內**（降幅超過 95%）
- 修復後報表排程**再也沒有發生過 OOM**，穩定處理 50 萬筆以上的資料量
- 建立了可複用的 Stream 匯出模式，後續其他匯出功能一併改造，杜絕同類問題