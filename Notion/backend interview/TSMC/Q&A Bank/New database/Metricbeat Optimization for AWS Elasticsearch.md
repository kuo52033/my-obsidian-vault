---
notion-id: 2ea5a6e2-1812-805d-8c3e-dd63c372ca35
base: "[[New database.base]]"
指派: []
狀態: 完成
---
### Q1: 為什麼你的 Metricbeat 設定中要特別使用 `metricbeat-oss` 版本？

> 建議回答 (STAR):(Situation) 我們公司使用 AWS 託管的 Elasticsearch (OpenSearch)，它是基於 Open Source 版本的。
(Task) 在部署官方 Metricbeat 時，發現它會不斷報錯，無法連線。
(Action) 經查閱 Log 發現是 /_license 檢查失敗。這是因為官方版包含商業功能 (X-Pack)，啟動時會驗證授權，而 AWS ES 不支援此 API。
(Result) 我將映像檔切換為 metricbeat-oss 版本，並在 ConfigMap 中明確關閉 setup.xpack 相關檢查，成功解決了連線問題，確保監控數據穩定寫入。

### Q2: 你的設定檔中用了很複雜的 `processors`，為什麼不把所有資料都收下來再說？

> 建議回答 (Cost & Performance):
這是為了 成本優化 (Cost Optimization) 與 降噪 (Noise Reduction)。
在 K8s 環境中，Pod 數量可能非常多（包含系統組件、CronJob 等）。如果全收，Elasticsearch 的儲存成本會很高，且查詢時會被雜訊干擾。
我使用了 drop_event 配合 正則表達式 (Regex) 實作「白名單機制」，只精準採集核心業務 (bms-management/platform) 的數據。同時使用 drop_fields 移除不必要的 Metadata，這樣做讓我們的索引大小減少了約 X%，顯著降低了 AWS 費用。

### Q3: 你把 `system` module 關掉了 (`enabled: false`)，這樣如果 Node CPU 爆了怎麼辦？

> 建議回答 (Architecture View):
這是一個權衡 (Trade-off)。
對於 Node 層級 (實體機/VM) 的監控，我們傾向依賴雲端供應商的原生工具 (如 AWS CloudWatch)，因為它不需要在 Cluster 內跑 Agent，且更貼近硬體層。
Metricbeat 則專注於 Pod/Container 層級 的顆粒度，用來分析具體的應用程式行為 (如 Memory Leak 或 Limit 設定不當)。這樣的職責分離讓監控架構更清晰。

### Q4: 為什麼選擇用 DaemonSet 部署 Metricbeat，而不是在每個 Pod 裡放 Sidecar？

> 建議回答 (K8s Pattern):
為了 資源效率 (Efficiency)。
> 1. **Sidecar 模式：** 如果有 100 個 Pod，就要跑 100 個 Metricbeat，這會消耗大量額外的 CPU/Memory。
> 2. **DaemonSet 模式：** 每個 Node 只需要跑 **一個** Metricbeat，它就能透過 Kubelet API 監控該節點上所有的 Pod。這在資源使用上是最經濟的，也是 K8s 監控的最佳實踐 (Best Practice)。