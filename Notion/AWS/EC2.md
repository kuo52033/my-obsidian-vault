---
notion-id: cd4a5b4c-caeb-4502-8028-ff5fd9139831
---
Elastic Compute Clude = Infrastructure as a Servise

- User Data: Ec2 user data is used to automate boot tasks, this script only run once at the instance first start
- EC2 instance: AMI(OS)+instance size (CPU&RAM)+Storage+Security Group+user data

## EC2 instance types

### naming convention

m5.2xlarge

- m: instance class
- 5: generation
- 2xlarge: size within the instance class

**General Purpose**: great for diversity of workload such as web server or code repositories

**Compute Optimized**: great for compute-intensive tasks that require high performance processors

**Memory Optimized: fast performance for workloads that process large data sets in memory (RAM)**

**Storage Optimized**: great for storage-intensive task that require high, sequential, read and write access to large data sets on local storage

## Security Group

fundamental of network security in AWS, they control how traffic is allowed into or out of EC2 instance (firewall)

- can be attached to mutiple instances
- locked down to a region/VPC combination
- All inbound traffic is blocked by default
- All outbound traffic is authorised by defult

### Ports

- 22 = SSH(Secure Shell) - log into a Linux instance
- 21 = FTP(File Transfer Protocal) - upload files into a file share
- 22 = SFTP(Secure File Transfer Protocal) - upload files using SSH
- 80 = HTTP - access unsecured websites
- 443 = HTTPS - access secured websites
- 3389 = RDP(Remote Desktop Protocal) - log into a Window instance

---

啟用ec2 linux 預設使用者名稱為 ec2-user

### ssh 連線指令

- ssh -i ~\aws\myServerKey.pem ec2-user@54.95.83.166
    - ~\aws\myServerKey.pem : ssh key
    - ec2-user : 登入的使用者
    - 54.95.83.166 : public IP 

## NEVER enter your IAM access key into EC2 instance，use IAM role attach to instance for credential