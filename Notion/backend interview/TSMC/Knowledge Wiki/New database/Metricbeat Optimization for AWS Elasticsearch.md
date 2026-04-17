---
notion-id: 2ea5a6e2-1812-805e-b52a-cc775cc2e331
base: "[[New database.base]]"
多選:
  - K8S
  - Observability
狀態: 完成
---
### 1. 架構概述 (Architecture Overview)

- **採集層 (Agent):** 使用 Metricbeat (OSS 版本) 以 `DaemonSet` 方式部署在 K8s Node 上。
- **傳輸層 (Pipeline):** **Direct-to-ES**。不經過 Logstash，減少中介延遲與資源消耗。
- **儲存層 (Storage):** AWS Elasticsearch (Open Source 版本)。
- **目標:** 監控特定核心服務 (`bms-management`, `bms-platform`) 的 Pod 與 Container 資源使用量。

| **決策點** | **設定內容** | **原因與效益 (Why)** |
| --- | --- | --- |
| **映像檔選擇** | `metricbeat-oss:7.10.2` | **解決相容性問題。** AWS ES 不支援 Elastic 官方版的 License 檢查 (`/_license` API)，使用 OSS 版可避開 `unauthorized` 錯誤。 |
| **資料過濾** | `drop_event` + `regexp` | **節省成本。** 透過白名單 (Allowlist) 只保留 `bms` namespace 下符合正則表達式的核心 Pod，過濾掉 Sidecar 或其他雜訊。 |
| **欄位瘦身** | `drop_fields` | **減少索引大小。** 移除了 `agent`, `ecs`, `host` 等通用欄位，只保留核心數據，提升查詢效能。 |
| **停用 System** | `module: system` -> `false` | **專注應用層。** 捨棄 Node/Process 層級監控，專注於 Pod/Container 的資源分配與 OOM 偵測。 |

```yaml
# 精準過濾策略：只收特定 Namespace 下的特定 Deployment
processors:
  - drop_event:
      when:
        not:
          and:
            - equals:
                kubernetes.namespace: "bms"
            - regexp: # 正則表達式白名單
                kubernetes.pod.name: "^(bms-management-deployment|bms-platform-deployment)"

# 兼容 AWS ES 的關鍵設定
setup.ilm.enabled: false          # AWS 不支援標準 ILM
setup.xpack.security.enabled: false # AWS 不支援 X-Pack
output.elasticsearch:
  hosts: ["https://your-aws-es-endpoint:443"]
```

[[Notion/backend interview/TSMC/Q&A Bank/New database/Metricbeat Optimization for AWS Elasticsearch]] 