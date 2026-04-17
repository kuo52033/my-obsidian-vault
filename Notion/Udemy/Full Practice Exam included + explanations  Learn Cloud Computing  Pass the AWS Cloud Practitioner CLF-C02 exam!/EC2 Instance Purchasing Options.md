---
notion-id: 2af5a6e2-1812-801c-9056-f98d519ab68d
---
> EC2 有很多購買方式，每種針對不同使用情境、成本、可預期性、工作負載特性。

---

# 🔥 一張表總結所有 Purchasing Options（考試常考）

| 方案 | 適用情況 | 優點 | 缺點 |
| --- | --- | --- | --- |
| **On-Demand** | 不確定流量、短期、突發 | 彈性最高 | 價格最貴 |
| **Reserved Instances（RI）** | 固定長期 workload（如 DB） | 可省最多（最高 ~72%） | 需要 1–3 年承諾、不靈活 |
| **Convertible RI** | 長期 workload，但會更換機型 | 可換 instance family | 折扣略少（~66%） |
| **Savings Plans** | 長期 workload，但不想綁特定 instance | 最彈性的折扣方案 | 需承諾固定「金額」 |
| **Spot Instances** | 可中斷的 workload（Batch, ML, Image processing） | 最便宜（~90% off） | 可能隨時被回收 |
| **Dedicated Hosts** | 合規性、要帶 license（BYOL） | 提供物理主機控制 | 超級貴 |
| **Dedicated Instances** | 不跟其他客戶共享硬體 | 提升隔離等級 | 控制權比 Host 少 |
| **Capacity Reservations** | 在某 AZ 一定要有 capacity（例如重要事件） | 確保資源 | 也很貴、不提供折扣 |

---

# 📌 各種購買方式具體是什麼？

## 1️⃣ On-Demand（你最常用）

- *按秒計費（Linux/Windows）*
- 短期、不確定 workload 最適合
- 無承諾 → 貴但彈性最高

適合:

- 新專案
- 無法預測的 traffic
- 測試環境

---

## 2️⃣ Reserved Instances（RI）

你承諾：**1 年或 3 年**

AWS 給你：**最高 ~72% 折扣**

適合：

- 固定流量的服務
- 長期跑的 database、API server

限制：

- 綁 instance type（不能亂換）
- 綁 region
- 綁 tenancy
- 依你買的 scope:
    - Region RI → 折扣
    - Zonal RI → 折扣 + 保留 capacity

---

## 3️⃣ Convertible Reserved Instances

比一般 RI 彈性更多：

- 可換 instance type
- 可換 instance family
- 可換 OS
- 可換 region/scope

折扣稍低（~66%）

適合：

- 想省錢但未來會更換機型的服務

---

## 4️⃣ Savings Plans（現代取代 RI）

你承諾：

> 「未來 1 或 3 年，每小時花多少美金」

例如：

> $10/hr 的 compute usage

AWS 給你：

- 跟 RI 一樣的折扣（最高 70%）

但優點更好：

- **不綁 instance type**
- **不綁大小（t3 → t3.large 都行）**
- **不綁 OS**
- **不綁 tenancy**

只綁：

- 特定 instance family（例如 M5）

適合：

- 想省錢又想彈性的公司
- 隨時可能 scale up/down 的 workload

---

## 5️⃣ Spot Instances

用剩下的 EC2 capacity → AWS 便宜賣

折扣：

> 最便宜，可達 90% off

但風險：

> AWS 只要需要，就會把你的 instance ‘收回’
> 給你 2 分鐘時間關掉

適合：

- Batch jobs
- 影像分析
- ML training
- 分散式運算

不適合：

- Database
- 長期任務
- 關鍵系統

---

## 6️⃣ Dedicated Host

> 整台物理機器都是你的

用途：

- 合規性（例如 Oracle/SQL Server license 要綁 CPU/socket）
- 想自己管理硬體層
- 極高的安全隔離需求

缺點：

- **最貴的 EC2 購買方式**

---

## 7️⃣ Dedicated Instances

> 實體機器不給別的 AWS 客戶使用，但可能跟你自己帳號的 instance 混用

適合：

- 想要隔離，但不需要 dedicated host 那麼強

---

## 8️⃣ Capacity Reservations

> 保留 AZ 的 instance capacity，不打折、照 on-demand 計費

用途：

- 你有重要活動（雙 11、開賣、直播）
- 一定要確保某 AZ 你能啟動 instance

缺點：

- 不打折
- 不管你有沒有用 → 都要付錢

可以搭配：

- Regional RI
- Savings Plans
👉 才能付比較少錢

---

# 🎯 考試常考題型（很準）

我整理最常考的情境給你：

| 問題 | 正確答案 |
| --- | --- |
| DB 需要長期、不可中斷 | **Reserved Instance** |
| ML Train, Image processing，可中斷 | **Spot** |
| 長期 workload，但 instance type 會變 | **Convertible RI** |
| 想省錢，但不想綁 instance type | **Savings Plans** |
| 合規性要控制硬體層 | **Dedicated Host** |
| 想確保 AZ 一定有早期容量 | **Capacity Reservation** |
| 新服務、還不知道 workload | **On-Demand** |