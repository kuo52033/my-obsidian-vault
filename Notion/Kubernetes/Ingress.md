---
notion-id: 8caae962-84b9-495c-8908-99e308a5706e
---
```yaml
apiVersion: extensions/v1beta1 # 目前 apiserver 只支援這個版本
kind: Ingress
metadata:
  name: helloworld
spec:
  rules: # Ingress 轉發規則
    - host: helloworld.com.tw # 可以連接到的網域名稱
      http:
        paths:
        - path: / # 可以連接到的路徑
          backend:
            serviceName: helloworld # 轉接的 service name (service.metadata.name)
            servicePort: 8080 # 經由哪個port 連接到service
```

*In order for the Ingress resource to work, the cluster must have an ingress controller running.*

![[螢幕擷取畫面_2024-03-26_160940.png]]