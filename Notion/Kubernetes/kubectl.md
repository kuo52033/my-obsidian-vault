---
notion-id: 025f5ac7-b1fa-4d2c-8c70-774db7d20855
---
| Command | to do |
| --- | --- |
| kubectl get <resource>/all | 查看各種資源資訊 |
| kubectl create <resource> <name> | 創建資源 |
| kubectl create -f <file name> | 配置文件創建資源 |
| kubectl edit <resource> <name> | 修改資源 |
| kubectl logs <pod name> | 查看日誌 |
| kubectl describe <resource> <name> | 查看資源詳細訊息 |
| kubectl exec -it <pod name> sh  | 進入pod |
| kubectl apply -f <file name> | 配置文件創建或更新資源 |
|  kubectl rollout status <resource> <name> | 查詢升級狀況 |
| kubectl rollout undo deployment <deployment> | 回到上個版本 (revision) |
| kubectl get pod -o wide | 查看pod屬於哪個node |
| kubectl config view | 查看 kubernates configuration |
|   |   |
