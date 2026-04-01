
### Situation（背景）

某次在 EKS cluster 部署更新後，立即收到多個客戶回報服務異常。調查 log 後發現 Kubernetes Service 的流量 routing 出錯 — targetPort 3000 的 service 收到了本應導向 port 3001 的請求，反之亦然。問題發生在共用同一個 VPC 的所有專案上。

### Task（任務）

作為值班工程師之一，我需要在最短時間內恢復服務，並找出 root cause。

### Action（行動）

1. **即時止血**：判斷問題出在 kube-proxy 的 iptables rules 更新異常後，評估在原 cluster 上修復的風險和時間成本太高，決定**將服務緊急遷移到一個新建的 cluster**
2. **快速遷移**：利用既有的部署腳本和 template YAML，在新 cluster 上重新建立完整環境，將流量切換過去
3. **Root Cause 分析**：事後確認是 kube-proxy 在特定情境下 iptables rules 未正確同步（疑似與 K8s 版本 1.22 相關的已知行為），導致 Service 的 backend 映射混亂
4. **推動架構改善**：將此事件作為推動 cluster 拆分策略的依據（→ Story 1）

### Result（成果）

- 從發現問題到服務完全恢復，總停機時間約 **5 小時**
- 事後推動了 cluster 隔離架構改造，根本性解決 blast radius 問題
- 建立了 incident response 的 SOP，包括快速遷移的 runbook
- K8s 升級到 1.28 後，類似問題未再發生