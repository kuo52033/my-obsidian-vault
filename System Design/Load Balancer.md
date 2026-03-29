A load balancer sits in front of your server and distributes incoming traffic across multiple instances.

![[Pasted image 20260327000901.png]]
### ALB

It inspects the HTTP request, can route to completely different backend services based on URL path, hostname, HTTP headers, or query strings
![[Pasted image 20260327001121.png]]
### Load Balancer algorithms
| Algorithm               | How it works                                  | Best for                                      |
| ----------------------- | --------------------------------------------- | --------------------------------------------- |
| **Round robin**         | Each server in turn, equally                  | Homogeneous servers, stateless apps           |
| **Least connections**   | Send to server with fewest active connections | Long-lived connections, variable request cost |
| **Least response time** | Send to fastest + least loaded server         | Latency-sensitive apps                        |
| **IP hash**             | Hash client IP → always same server           | Session stickiness                            |
| **Weighted**            | Give heavier servers more traffic             | Mixed instance sizes, canary deploys          |
### Health checking
![[Pasted image 20260327001906.png]]

In AWS load balancer lives in the public subnet, and the backend servers live in the private subnet.The LB is the only thing that has a ==public-facing IP==; your EC2s never need to be directly exposed.
```
Internet → IGW → ALB (public subnet) → EC2s (private subnet)
                 ↑ TLS terminates here if keeping certificates centralized on it.
```


> [!NOTE] 
> **TCP source IP is at the network level (trustworthy, automatic), X-Forwarded-For is an HTTP header (requires trust config, can be faked).** Kong/Nginx need a load balancer to get a stable public IP in cloud environments. ALB alone is enough for simple routing, but once you need JWT, rate limiting, plugins, or request transformation — you need Kong/Nginx regardless of which load balancer sits in front.
