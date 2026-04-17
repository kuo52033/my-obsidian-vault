---
notion-id: 3385a6e2-1812-80f2-8aaa-d33dd30b6364
base: "[[New database.base]]"
指派: []
狀態: 完成
---
我們的平台是多租戶架構，初期所有客戶的專案都在同一個 cluster。有一次發生了 iptables 異常，導致 VPC 內大部分服務都受到影響，爆炸半徑非常大。
事後我們討論根本原因，認為單一 cluster 的風險太集中，決定以客戶為單位拆分成多個獨立的 cluster，每個 cluster 有自己的 VPC 和 network，從根本上縮小故障的影響範圍。
cluster 內部的隔離我們也做了幾層：
首先用 namespace 做專案層級的隔離，搭配 nodeSelector 把不同服務部署到對應的 node group，確保工作負載不會混跑在同一批 node 上。
流量這塊，NGINX Ingress 用 podAntiAffinity 強制分散到不同 node，再搭配 externalTrafficPolicy Local，讓 NLB 的流量只打到有 NGINX Pod 的 node，避免跨 node 轉發，同時也保留了真實 client IP。
資源管理上，針對不同工作負載設定不同的 ResourceQuota，AP server 給較高的配額，排程任務給較低的，防止批次任務在尖峰時搶占 AP server 的資源。container 層級盡量讓 requests 等於 limits，維持 Guaranteed QoS class，確保重要服務不會因為資源競爭被降速或 OOMKilled。

deployment safety 我們做了幾層保護：
RollingUpdate 設 maxUnavailable: 0、maxSurge: 1，確保新 Pod ready 之前舊 Pod 不會被移除，服務容量不會下降。
readiness probe 打 /health endpoint，確認服務真正就緒後才讓 NLB 把流量切進來。liveness probe 則是偵測服務異常時自動重啟。
Node.js 這端有處理 SIGTERM，rolling update 移除舊 Pod 時，呼叫 server.close()，停止接收新的連線， 會等當下的 request 處理完才清理資源(db, redis…)
如果部署後發現問題，可以直接 kubectl rollout undo 回到上一版，不需要重新跑 CI。

### Situation

公司產品是一個多租戶的金融管理平台，當時所有客戶的專案都部署在同一個 EKS cluster、同一個 VPC 內。因為所有專案共用同一個 VPC，影響範圍擴散到所有客戶，造成了**約 5 小時的服務中斷**。

### Task

事件緊急處理後，我與 Senior 工程師和主管討論，決定從架構層面根本解決「爆炸半徑（blast radius）」過大的問題。我被指派**獨立負責其中一個新 cluster 的規劃與建置**，從 infra 到部署 YAML 全權負責。

### Action

**1. Cluster 級隔離 — 以客戶為單位拆分**

- 將原本的單一 cluster 拆分為 **4 個獨立 cluster**，每個 cluster 對應一個客戶（含 3~4 個專案）
- 每個 cluster 配置獨立的 VPC，確保網路層完全隔離，即使某個 cluster 出問題也不會影響其他客戶

**2. Namespace 級隔離 — 以專案為單位劃分**

- 在 cluster 內以 namespace 區分不同專案（例如 `bms` namespace 負責金融管理系統）
- 搭配 `nodeSelector`（`app: bms, env: production`）將工作負載綁定到特定節點群組，避免 noisy neighbor

**3. 資源配額管理 — 按角色分級配置**

- 針對不同類型的工作負載設定差異化的 ResourceQuota / LimitRange：
    - **AP Server**（面向用戶）：CPU 2 core / Memory 2Gi
    - **Cronjob**（排程任務）：CPU 0.5~1 core / Memory 0.5Gi
    - **MQ Worker**（訊息處理）：CPU 0.5 core / Memory 0.5Gi
- 防止背景任務（報表計算、資料統計）搶占 API Server 的資源

**4. 部署安全策略**

- 所有 Deployment 統一使用 `RollingUpdate` 策略，設定 `maxSurge: 1, maxUnavailable: 0` 確保零停機部署
- NGINX Ingress Controller 設定 `podAntiAffinity`，將 replica 分散到不同 node，避免單點故障
- 面向用戶的 AP Server 設定 `livenessProbe` 健康檢查，異常時自動重啟

**5. 可觀測性建設**

- 部署 Filebeat DaemonSet 收集應用日誌，經 Logstash 結構化後送入 AWS OpenSearch
- 部署 Metricbeat DaemonSet 監控 Pod/Container 層級的 CPU、Memory 指標，針對關鍵服務（management / platform）做重點監控

### Result

- Cluster 拆分後，**單一故障的影響範圍從「全部客戶」縮小到「單一客戶」**，blast radius 縮小約 75%
- 後續進行 K8s 版本升級（1.22 → 1.28）及多次部署，**未再發生 iptables routing 異常**
- 資源配額機制有效防止了 scheduler 類 cronjob 在大量運算時搶占 API 服務資源的情況
- 建立了一套可複製的 cluster 建置流程（deploy.sh + template YAML），後續新客戶上線可快速套用