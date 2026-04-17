---
notion-id: 4bbc047a-a1d2-40c8-a624-e8a11a7cb472
---
AI:

Amazon Elastic Block Store (EBS) is a high-performance block storage service designed for use with Amazon Elastic Compute Cloud (EC2) for both throughput and transaction intensive workloads at any scale. It provides a range of options that allow you to optimize storage performance and cost. These options are well suited for a variety of use cases, like running business-critical applications, relational and non-relational databases, and big data analytics engines, and for workloads that require fine-tuning for performance and cost.

---

- EBS(Elastic Block Store) volumn is a network drive you can attach to your instance while they run
- it allow instance for persist data, even after their termination
- EBS is bound to a specific availability zone
- By default, the root EBS volumn is deleted on termination
- By default, the other attached EBS volumn is not deleted on termination

## EBS snapshot

we can use EBS to do a snapshot, and that could quote unquote copy EBS volumn across different availability zone 

### Recycle Bin

protect EBS snapshot and AMI from accidental deletion

## AMI

AMI (Amazon Machine Image): a customization of an EC2 instance

- add your own software, configuration, OS, monitoring….
- Faster boot time because all your software is pre-packaged
- we can use existing instance to build an AMI

## EFS

EFS = Elastic File System, is a shared network file system that can be mounted on 100s of EC2 instances, only with Linux

- high available
- scalable
- pay per use, no capacity planning

![[螢幕擷取畫面_2024-03-21_210735.png]]


## Summary

![[螢幕擷取畫面_2024-03-21_211720.png]]
