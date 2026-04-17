---
notion-id: 2e95a6e2-1812-804e-882e-e961558c5315
base: "[[New database.base]]"
多選:
  - Architecture
  - aws
  - Availability
狀態: 完成
---
### AWS Auto Scaling Group (ASG)

- **定義:** 管理 EC2 實例群組的 AWS 服務，負責水平擴充與健康管理。
- **關鍵參數:**
    - **Min Size:** 離峰時最少要保留幾台 (確保服務不中斷)。
    - **Max Size:** 高峰時最多能開幾台 (防止成本失控)。
    - **Desired Capacity:** 目前期望運行的數量。
- **與 K8s 的關係:**
    - 在 EKS 環境中，ASG 管理的是 **Worker Nodes (底層機器)**。
    - **Cluster Autoscaler** 會修改 ASG 的 `Desired Capacity` 來增加節點。


### 1. 什麼是 ASG？ (Core Concept)

**ASG (Auto Scaling Group)** 是一個邏輯上的群組，用來管理一群設定相同的 EC2 實例 (Instances)。它的核心任務只有兩個：

1. **確保數量 (Capacity Management)：** 永遠保持您設定的機器數量（例如：最少 2 台）。
2. **自動伸縮 (Elasticity)：** 根據負載（CPU、Request 數量）自動增加或減少機器。

### 2. ASG 的三大關鍵功能 (The "Why")

在面試中，當被問到「為什麼要用 ASG？」時，請回答這三點：

### A. 動態擴展 (Dynamic Scaling)

這是最直觀的功能。

- **Scale-out:** 當 CloudWatch 偵測到 CPU 使用率 > 60%，ASG 自動啟動新機器加入服務。
- **Scale-in:** 當半夜沒人時，CPU < 30%，ASG 自動關閉機器以節省成本。
- *這對應到您第一週主題中的「水平擴充」。*

### B. 自癒能力 (Health Check & Self-healing)

即便系統負載不高，ASG 也會隨時監控機器健康狀態。

- 如果某台 EC2 的硬體壞了，或者被應用層判定不健康 (Unhealthy)，ASG 會**主動終止 (Terminate)** 那台壞掉的機器，並**自動啟動**一台新的來遞補。
- 這保證了系統具備「自我修復」的能力。

### C. 整合負載平衡 (Load Balancer Integration)

- ASG 通常與 ELB (Elastic Load Balancer) 搭配使用。
- 當 ASG 啟動一台新 EC2 時，它會自動把這台機器「註冊」到 ELB 的 Target Group 中，讓流量可以流進來；反之，縮容時會先「取消註冊 (Deregister)」再關機。