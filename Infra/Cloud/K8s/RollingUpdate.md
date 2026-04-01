kubernetes 的部署新版本策略，核心是不停機、逐步替換，不一次把全 pod 砍掉再重建

```yaml
spec:
  replicas: 4
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1 
      maxSurge: 1 
```

### maxUnavailable

在更新過程中，最多有幾個 pod 是不可用的狀態。

不可用(不在 ready 狀態)
- 正在被刪除的舊 Pod
- 新 Pod 還沒通過 Readiness Probe
- Pod crash 了

```yaml
replicas: 4 
maxUnavailable: 1
```

==任何時間點， ready 的 pod 數不能少於 4-1 = 3 個==

```
初始：     [v1✅] [v1✅] [v1✅] [v1✅] Ready = 4
Step 1：  砍一個 v1
          [v1✅] [v1✅] [v1✅] [v1❌] Ready = 3  ← 不能再砍
Step 2：  開一個 v2，等它 Ready
          [v1✅] [v1✅] [v1✅] [v1❌] [v2⏳]   Ready = 3
Step 3：  v2 通過 Readiness Probe
		  [v1✅] [v1✅] [v1✅] [v2✅]    Ready = 4  ← 恢復滿額，可以繼續
Step 4：  再砍一個 v1
          [v1✅] [v1✅] [v2✅] [v1❌]    Ready = 3
...
```

---

### maxSurge

更新過程中，最多可以額外多開幾個 Pod 