---
notion-id: e854fe01-2324-44ff-b024-0e8ed18fb04e
---
K8s 解決 : 手動部屬多個容器到不同的機器上，並要監控這些容器的狀態十分麻煩，因此提供一個平台以高層次的抽象化去自動化操作以及管理容器們。

- high availability or no downtime
- scalability or high performance
- disaster recovery - backup and restore
![[k8s_components.png]]

### Pod

- k8s 運作的最小單位，一個 pod 對應到一個應用服務，例如一個 API server，一個 pod 裡可有一到多個容器，但一般情況只會有一個。

### Worker Node

- k8s 運作的最小硬體單位，一台實體電腦或虛擬機( EC2 )
    - kubelet: 負責管理該 node 所有 pod 的運行狀態並負責跟 Master Node 做溝通
    - kube-proxy: 負責更新 node 的 iptables，使發送到 Service 的流量可以導至正確的 pod
    - container runtime: 負責執行容器，例如 docker 對應到的 docker engine

### Master Node

- k8s 運作的指揮中心，負責管理其他 worker node
    - API Server: 負責管理整個 cluster 的 api endpoint，node 之間的溝通橋樑，以及請求的身分驗證與授權
    - etcd: is a key-value store, holds the current status of any k8s component ，故障時可以透過 etcd 還原狀態 ( backing store)
    - Scheduler: pod 的調度員，根據資源分配去協調出一個適合的 node 讓 pod 運行 (ensures pod placement)
    - Controller Manager: 負責運行 k8s controller 組件 ( node controller, replication controller)，當 cluster 與預期狀態不符合時會更新現有狀態，contoller 的監視與更新都必須透過 apiserver 運行 (keep track of what happening in the cluster)

### Cluster

- k8s 中多個 node 與 master (control plane) 的組合

---

新增pod → command line → 身分驗證 → control plane apiserver → etcd 備份指令 → controller maneger 收到訊息並檢查資源是否允許 → scheduler 送到最適合的 node 上