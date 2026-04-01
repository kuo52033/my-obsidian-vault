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
