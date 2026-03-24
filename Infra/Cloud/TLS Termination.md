

Is the process of decrypting encrypted TLS/SSL traffic at a proxy or load balancer in the network infrastructure, rather than at the final destination server.
```
Client  ──[HTTPS/TLS]──▶  Load Balancer  ──[HTTP]──▶  Backend Servers
                          (TLS terminates here)
```

### Why
- ==offload CPU cost== - TLS handshakes and crypto are expensive. Free backend servers to focus on application logic.
- ==Centralized certificate management== - One cert in one place, instead of deploying/renewing certs across every backend node.
- ==Simplified backends== - Internal services can speak plain HTTP, which is simpler to configure, debug, and log.
- **==Inspection & routing==** — Once decrypted, the proxy can inspect headers, route based on URL path, apply WAF rules, rate-limit, etc. — ==none of which is possible with encrypted traffic.==
### Trade-off
Once terminated, traffic inside your network is **unencrypted**. This is acceptable if your internal network is trusted (private VPC, etc.)

### Summary
TLS termination is a practical architectural pattern that trades **end-to-end encryption for operational simplicity and performance** — with the assumption that the internal network is secure.