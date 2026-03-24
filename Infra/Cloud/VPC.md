A **VPC** is your own logically isolated network inside AWS — think of it as renting a ==private section== of the AWS datacenter where you control the IP ranges, subnets, routing, and access rules.
![[Pasted image 20260324162542.png]]
### Subnets

Each subnet bound to one Availability Zone, has public and private subnet
![[Pasted image 20260324162819.png]]
### Internal Gateway and NAT Gateway

- IGW: ==attached to the VPC==, allows resources in public subnet to send/receive traffic from the internet.
- NAT Gateway: ==sits in the _public_ subnet==, lets resources in _private_ subnets make outbound internet calls (e.g. to download packages) without being directly reachable from outside.
![[Pasted image 20260324163119.png]]
### Route Tables
Every subnet has a route table that determines where traffic goes.

|Subnet|Destination|Target|
|---|---|---|
|Public|`0.0.0.0/0`|Internet Gateway|
|Private|`0.0.0.0/0`|NAT Gateway|
|Both|`10.0.0.0/16`|local (within VPC)|

### Security Groups & NACLs
