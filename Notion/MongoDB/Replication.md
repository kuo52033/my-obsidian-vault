---
notion-id: 664c5da2-1ed7-4f4f-aac4-9cd64ad68a4b
---
Replication provides redundancy and increases [data availability](https://www.mongodb.com/docs/v4.0/reference/glossary/#term-high-availability)，for dedicated purposes, such as disaster recovery, reporting, or backup.

![](https://www.mongodb.com/docs/v4.0/_images/replica-set-read-write-operations-primary.bakedsvg.svg)

### P**rimary : The primary receives all write operations.**

### Secondary : Secondaries replicate operations from the primary to maintain an identical data set ，replicate the primary log and apply the operations to their data sets.

A secondary can become a primary. If the current primary becomes unavailable, the replica set holds an election to choose which of the secondaries becomes the new primary.
