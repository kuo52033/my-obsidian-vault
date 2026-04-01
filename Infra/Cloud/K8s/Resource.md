
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

request
- Scheduler 用來決定這個 pod 能不能放到某個 node
- Node 上的可用資源 = node 總資源 - 所有 Pod 的 requests 加總
- 預留位置

limits
- 實際執行的硬上限
- CPU 超過 -> throttle (降速，不會整個掛)
- Memoty 超過 -> OOMKilled (直接砍掉)

```
    resources 
		↓ 
LimitRange 檢查：這個 container 的值有沒有在 min~max 範圍內？         ↓   如果沒填，自動 inject default 值
ResourceQuota 檢查：加上這個 Pod 之後，namespace 總量有沒有超標？
		↓ 
通過 → Pod 建立成功
```

---
設置一樣 (Guaranteed)
```yaml
resources:
  requests:
    cpu: "500m"
    memory: "512Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"
```

代表預留多少，就最大能用多少，這塊資源是獨佔的，不會跟別人搶，適合==不希望有效能抖動的場景 (DB、cache)==。

設置不一樣 (Burstable)
```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"
  limits:
    cpu: "500m"
    memory: "512Mi"
```

代表平常只預留一點，但需要的時候可以暫時衝到更高，node 可以塞進更多的 pod，執行時如果 node 有閒置資源，可以用到 500m，但忙的時候可能會被壓縮回 100m。


> [!NOTE] 
> requests 設低 → node 可以塞更多 Pod，資源使用率高，但競爭時效能不穩定 
> requests 設高 → node 塞的 Pod 少，資源使用率低，但效能穩定可預期 
> limits 設低 → 保護 node 上其他 Pod，但自己容易被 throttle/OOMKilled 
> limits 設高 → 自己有彈性，但可能影響鄰居
