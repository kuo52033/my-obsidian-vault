---
notion-id: b2af3d29-0efa-48f4-b826-7c1deb40e0e6
---
- Permanent IP address
- Lifecycle of pod and Service not connected
- Internal Service is the default type

```yaml
apiVersion: v1
kind: Service
metadata:
  name: chat-service
  namespace: default
spec:
  type: NodePort # default = clusterIP 用來做內部溝通，NodePort 用來對外
  selector:
    app: chat
  ports:
    - protocol: TCP
      port: 3005 # service開放的
      targetPort: 3005 # pod開放的
      nodePort: 30000 # (30000~32767) 對外端口 only NodePort
```
