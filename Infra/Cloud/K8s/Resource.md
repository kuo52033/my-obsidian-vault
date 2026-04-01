
### ResourceQuota 

控制某個 namespace 可以使用的資源上限，防止某個 team/service 把 cluster 的資源吃光
```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-quota
  namespace: dev
spec:
  hard:
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
    pods: "20" # 數量
    services: "10"
```

只要 namespace 內的所有 pod 資源加總超過 quota，新的 pod 就會被拒絕建立

---

### LimitRange

控制 **單一 Pod 或 Container** 的資源範圍，同時可以設定沒有填寫 resources 時的 default 值。

```YAML
apiVersion: v1
kind: LimitRange
metadata:
  name: dev-limits
  namespace: dev
spec:
  limits:
  - type: Container
    default:           # 沒寫 limits 時自動套用
      cpu: 500m
      memory: 256Mi
    defaultRequest:    # 沒寫 requests 時自動套用
      cpu: 100m
      memory: 128Mi
    max:               # 單一 container 上限
      cpu: "2"
      memory: 2Gi
    min:               # 單一 container 下限
      cpu: 50m
      memory: 64Mi
```

---
### Resource

寫在每個 pod spec 裡 container 的 recources 欄位，

```yaml
containers:
  - name: my-app
    image: my-image
    resources:
      requests:       # ← 排程依據，scheduler 看這個決定放到哪個 node
        cpu: "0.1"
        memory: "200Mi"
      limits:         # ← 硬上限，超過就被 throttle / OOMKilled
        cpu: "2"
        memory: "2.0Gi"
```

