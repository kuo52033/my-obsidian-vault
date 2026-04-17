---
notion-id: 613cbed7-e987-462f-8822-aa312df8d765
---
![[ke4Q0Y9.png]]

### VPC (region resource)

VPC (Virtual Private Cloud), you can launch AWS resoures in a logically isolated virtual network that you’ve defined.

### Subnets (AZ resource)

A subnet is a range of IP address in your VPC, must reside in a single AZ. Has public subnets and private subnets

### Routes Table

Contains a set of rules (routes) to determine where network traffic from your subnet or gateway

### Internet Gateway

Helps our VPC instances connect to the internet, public subnets have a route to the internet gateway

### NAT Gateway

Enables instances in a private subnet to send outbound traffic to the internet, but prevents resources on the internet from connecting to the instances

![[螢幕擷取畫面_2024-04-23_113936.png]]

### VPC Endpoint

Endpoints allow you to connect to AWS services using a private network instead of the public www network, it gave you enhanced security and lower latency to access AWS services