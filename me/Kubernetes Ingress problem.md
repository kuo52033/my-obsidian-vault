### Situation

在多專案共用的 EKS cluster 中，`bms` namespace 的 `nginx-ingress-controller` 三天內觸發了 **21,936 次 Sync 事件**。調查後發現 `bms-management-ingress` 的 `status.loadBalancer.ingress.hostname` 不斷被改寫成其他專案的 NLB hostname，導致流量路由間歇性異常 — 使用者有時能正常存取，有時被導向錯誤的服務。

### Task

找出 Ingress hostname 反覆被改寫的 root cause，修復問題並建立防護機制，防止多專案環境下的跨專案干擾再次發生。

### Action

**1. Root Cause 分析**

逐層排查後確認三個交織的問題：

- **Controller 干擾**：其他專案的 `nginx-ingress-controller` 沒有設定 `--watch-namespace`，導致它們會掃描並更新所有 namespace 的 Ingress 資源，包括 `bms` 的
- **NLB name 衝突**：多個專案的 Service 可能映射到相同的 NLB，造成 hostname 互相覆蓋
- **IngressClass 缺失**：`bms` 的 Ingress 設了 `ingressClassName: bms`，但沒有建立對應的 `IngressClass` resource，在多 controller 環境下行為不明確

**2. 即時修復 — Pod 調度與隔離**

- 為 `nginx-ingress-controller` 加入 `nodeAffinity`，確保只調度到標記 `app: bms, env: production` 的節點上，使 NLB target group 只包含正確的 node
- 加入 `podAntiAffinity`（`preferredDuringSchedulingIgnoredDuringExecution`），將 ingress controller Pod 分散到不同 node，提升 HA
- 設定 `ingressClassName: bms` 搭配 controller 的 `--ingress-class=bms` 參數，減少其他 controller 的干擾

**3. 長期改善建議（提交給團隊）**

- 建立正式的 `IngressClass` resource，標準化 controller 與 Ingress 的對應關係
- 要求所有專案的 ingress controller 必須設定 `--watch-namespace`，強制 namespace 隔離
- 為 NLB 設定有意義的唯一名稱（例如 `bms-prod-nlb`），取代自動生成的 hash 名稱
- 建立監控機制：watch Ingress 變更事件、定期檢查 NLB target group 健康狀態

### Result

- 修復後 **Sync 事件從三天 21,936 次降至正常水平**，Ingress hostname 穩定不再被改寫
- `podAntiAffinity` 提升了 ingress controller 的高可用性，消除了單節點故障風險
- 撰寫了完整的問題分析報告（Notion），包含 root cause、修復措施、長期建議，作為團隊的知識庫留存
- 這次排查經驗也成為後續推動 cluster 隔離策略（Story 1）的重要依據之一