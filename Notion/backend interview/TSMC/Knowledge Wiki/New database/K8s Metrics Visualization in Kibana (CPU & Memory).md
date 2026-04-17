---
notion-id: 2ea5a6e2-1812-80f8-9f43-f63fd77bd8e7
base: "[[New database.base]]"
多選:
  - Observability
  - K8S
狀態: 完成
---
### 1. 挑戰與目標 (Objective)

- **原始數據難以閱讀：** Metricbeat 收集的原始數據單位極小（CPU 為 `nanocores`，Memory 為 `bytes`），在儀表板上顯示 `5,000,000` 或 `173,015,040` 難以直觀判斷。
- **目標：** 透過 Kibana 的 **Scripted Fields (Painless)** 將數據轉換為業界通用的 **Millicores (m)** 與 **Mebibytes (MiB)**，以便進行容量規劃。

### 2. 實作細節 (Implementation)

使用 **Painless Script** 進行即時運算：

- **CPU (Nanocores to Millicores):**
    - 公式：`doc['kubernetes.pod.cpu.usage.nanocores'].value / 1,000,000.0`
    - 意義：將 10億分之一核轉為千分之一核。
- **Memory (Bytes to MiB):**
    - 公式：`doc['kubernetes.pod.memory.usage.bytes'].value / 1024.0 / 1024.0`
    - 意義：除兩次 1024 將 Bytes 轉為 MiB。

### 3. 數據解讀與分析 (Data Analysis)

根據實際儀表板 (參見截圖)：

| **指標** | **觀測數值** | **狀態解讀** | **維運決策建議** |
| --- | --- | --- | --- |
| **CPU Usage** | **~5m** (0.005 Core) | **極度閒置 (Idle)**。Pod 幾乎只有背景心跳。 | 若長期如此，可考慮降低 K8s CPU Request 以節省 Cluster 資源。 |
| **Memory Usage** | **~165 MiB** (Management)<br>**~50 MiB** (Platform) | **平穩 (Stable)**。曲線呈水平直線，無明顯上升趨勢。 | 目前無 Memory Leak。建議將 Memory Request 設為 200Mi (留緩衝)，Limit 設為 300Mi (防止突波)。 |

![[截圖_2026-01-16_17.07.16.png]]

![[截圖_2026-01-16_17.19.02.png]]