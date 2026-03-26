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
