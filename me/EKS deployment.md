### Situation（背景）

公司產品是一個多租戶的金融管理平台，當時所有客戶的專案都部署在同一個 EKS cluster、同一個 VPC 內。某次部署後，疑似 kube-proxy 的 iptables rules 發生異常，Service routing 出錯 — 原本應該轉發到 targetPort 3000 的流量被送往 port 3001，導致跨專案的請求混亂。因為所有專案共用同一個 VPC，影響範圍擴散到所有客戶，造成了**約 5 小時的服務中斷**。

### Task（任務）

事件緊急處理後，我與 Senior 工程師和主管討論，決定從架構層面根本解決「爆炸半徑（blast radius）」過大的問題。我被指派**獨立負責其中一個新 cluster 的規劃與建置**，從 infra 到部署 YAML 全權負責。

### Action（行動）

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

### Result（成果）

- Cluster 拆分後，**單一故障的影響範圍從「全部客戶」縮小到「單一客戶」**，blast radius 縮小約 75%
- 後續進行 K8s 版本升級（1.22 → 1.28）及多次部署，**未再發生 iptables routing 異常**
- 資源配額機制有效防止了 scheduler 類 cronjob 在大量運算時搶占 API 服務資源的情況
- 建立了一套可複製的 cluster 建置流程（deploy.sh + template YAML），後續新客戶上線可快速套用