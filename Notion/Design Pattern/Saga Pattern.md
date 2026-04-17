---
notion-id: 1dc40fac-144c-48eb-a590-4876c592b133
---
The Saga pattern is a design pattern in microservices architecture that helps to manage transactions that span multiple services. It's typically used to ensure data consistency across services in distributed systems.

A Saga is essentially a sequence of local transactions where each transaction updates data within a single service. If all transactions complete successfully, then the Saga has completed. If a transaction fails, the Saga executes compensating transactions to undo the impact of the preceding transactions.

The Saga pattern comes in two flavors: choreography and orchestration. In the choreography style, each local transaction publishes an event at its completion, and other local transactions subscribe to events and execute based on these. In the orchestration style, there is a central coordinator (or orchestrator) that tells the participants what transaction to execute, in what order, and also handles compensating transactions in the case of failures.

The Saga pattern can be a valuable tool to ensure consistency in a microservices architecture, but it also requires careful design and consideration of how to handle failures.