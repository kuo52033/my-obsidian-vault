![[Pasted image 20260323233238.png]]
![[Pasted image 20260402151528.png]]
- 在 Cloudflare 做 TLS Termination 會導致 Cloudflare 到 origin 走的是明文 (Flexible SSL mode)，雖然流量在 Cloudflare 和 AWS 之間網路傳輸，風險是相對可控，但如果要更嚴謹，可以改成 Full (strict) mode，到 origin 走的都是https，NLB 上掛憑證再做解密。

