![[Pasted image 20260323233148.png]]
## TLS Termination

Is the process of decrypting encrypted TLS/SSL traffic at a proxy or load balancer in the network infrastructure, rather than at the final destination server.
```
Client  ──[HTTPS/TLS]──▶  Load Balancer  ──[HTTP]──▶  Backend Servers
                          (TLS terminates here)
```

### Why
- ==offload CPU cost== - TLS handshakes and crypto are expensive. Free backend servers to focus on application logic.
- ==Centralized certificate management== - One cert in one place, instead of deploying/renewing certs across every backend node.
- 

![[Pasted image 20260323234608.png]]
![[Pasted image 20260324003816.png]]
![[Pasted image 20260324141352.png]]
