---
notion-id: 481ae568-94de-4448-82f2-6a042a654db6
---
## cgroup

On Linux, [control groups](https://kubernetes.io/docs/reference/glossary/?all=true#term-cgroup) are used to constrain resources that are allocated to processes.

Both the [kubelet](https://kubernetes.io/docs/reference/generated/kubelet) and the underlying container runtime need to interface with control groups to enforce [resource management for pods and containers](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) and set resources such as cpu/memory requests and limits. To interface with control groups, the kubelet and the container runtime need to use a *cgroup driver*. It's critical that the kubelet and the container runtime use the same cgroup driver and are configured the same.


**Starting with v1.22 and later, when creating a cluster with kubeadm, if the user does not set the **`**cgroupDriver**`** field under **`**KubeletConfiguration**`**, kubeadm defaults it to **`**systemd**`**.**

## CRI (Container Runtime Interface)

- containerd：管理容器的整個生命週期，包括從鏡像的傳輸、儲存到容器的執行、監控再到網路， docker 建立的，並遵守 CRI 規範
- CRI : An API that allows you to use different container runtimes in Kubernetes.
- OCI:  a set of standards for containers, describing the image format, runtime, and distribution.
- 一開始，k8s 使用 docker engine 來跑 container，後來 k8s 產生 CRI 來支援不同 container runtime 也可以使用，但是 docker engine 並沒有實作 CRI ，所以 k8s 產生 dockershim 來讓 docker 也能使用。但在 k8s 1.24 版本後，dockershim 將完全移除，這意味著要使用 containerd  或 CRI-O 來跑 docker image，並不須要使用 docker 指令或 docker daemon
