---
notion-id: 7071e531-f914-4974-a036-493961da8edf
---
```yaml
apiVersion: apps/v1 # 與apiserver 溝通的版本
kind: Deployment # 資源類型
metadata:
  name: chat-deployment
  namespace: default
spec: # deployment 的配置規範
  replicas: 1 # 這個 replicaSet 有幾個 pod (desire status)
  selector: # 選擇特定的資源，對應到底下 pod 的 label
    matchLabels:
      app: chat
  strategy:
    type: RollingUpdate # 滾動更新，達到 zero downtime depolyment, or Recreate 會先砍掉舊的再產生新的pod
    rollingUpdate:
      maxSurge: 1 # 在更新時可以產生比 replicas 還多幾個 pod, ex. maxSurge: 1、replicas: 5，代表 Kubernetes 會先開好 1 個新 pod 後才刪掉一個舊的 pod，整個升級過程中最多會有 5+1 個 pod
      maxUnavailable: 1 # 在更新時可以允許多少個 pod 無法服務
  minReadySeconds: 60 # 在新的pod建立完後須要等多久才能接受 request, default = 0
  revisionHistoryLimit: 10 # 需要保留幾個紀錄(revision)
  template:
    metadata:
      labels:
        app: chat
    spec:
      containers:
        - name: chat
          image: kuo52033/chat-demo:production-2.4
          ports:
            - containerPort: 3005
          command: ["pm2-runtime"]
          args: ["start", "./pm2-processes/production.json", "--only", "chat-1"]
          livenessProbe:
            httpGet:
              path: /health
              port: 3005
            initialDelaySeconds: 30
            timeoutSeconds: 15
            successThreshold: 1
            periodSeconds: 15

					# pod /var/log/chat -> worker node /var/log/chat/production 
          volumeMounts:
            - name: log
              mountPath: /var/log/chat

      volumes:
        - name: log
          hostPath:
            # directory location on worker node
            path: /var/log/chat/production
            type: DirectoryOrCreate
```

![[螢幕擷取畫面_2024-03-26_165617.png]]