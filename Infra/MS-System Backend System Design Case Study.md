15) Optimization Stories (Repo-verified)
Story 1: Time-stat query path optimization (filter pushdown + pre-limit)
Problem: Time-stat query/export paths were expensive due to heavy scans and late filtering.
Change: Query logic was updated to use targeted SQL paths, bankAccountIds pre-filtering, and pre-limiting strategy in pagination-style queries.
Why it works: Reduces candidate row set before expensive sorting and post-processing.
Evidence: commit 8ee6fbd3, commit 6d8cbf5f, plus
server/stores/transaction-log.js
server/lib/excel-generator/deposit-time-statistics-report.js
server/lib/excel-generator/payment-time-statistics-report.js
Interview phrasing: “I reduced query pressure by shrinking the working set early and aligning export filters with query predicates. Measured numbers were not captured in repo, but the optimization is code- and migration-backed.”

Story 2: Covering index design for report workloads
Problem: Report queries over transaction_logs needed better index coverage for common filters/sorts.
Change: Added/updated idx_logs_report_cover and expanded indexed fields via migrations.
Why it works: Better index coverage reduces table lookups for frequent report predicate combinations.
Evidence:
migrations/52-1.29.3.js
migrations/53-1.29.4.js
server/schemas/mysql/transaction-log.js
Interview phrasing: “I treated report queries as a first-class workload and evolved indexes iteratively through migrations rather than ad-hoc DB edits.”

Story 3: Scheduler DB pool optimization (minPoolSize=0)
Problem: Multiple scheduler processes holding unnecessary minimum DB connections can waste resources during idle periods.
Change: Set scheduler-side DB pool min size to 0 and propagated support in DB connect wrapper.
Why it works: Frees idle DB connections while keeping process architecture unchanged.
Evidence: commit 5eb93a4e, plus
server/lib/database.js
bin/calculate-report-scheduler.js
bin/calculate-platform-data-scheduler.js
Interview phrasing: “I reduced baseline resource footprint by distinguishing API connection needs from scheduler burst patterns.”

Story 4: Data retention optimization with TTL-index rollout
Problem: High-volume log/derived tables can grow quickly and degrade operational efficiency.
Change: Introduced TTL index creation for multiple operational datasets via migration and fixture hooks.
Why it works: Keeps operational tables bounded and lowers long-tail query/storage overhead.
Evidence:
migrations/46-1.23.0.js
server/fixtures/fixture-transaction-log.js
server/fixtures/fixture-daily-balance.js
Interview phrasing: “I pushed retention policy into versioned migration workflows so data lifecycle was explicit and repeatable.”

16) Tradeoffs, Bottlenecks, and Scalable Redesign Options
Current tradeoffs:

In-process EventEmitter orchestration is simple but not durable across process/network boundaries.
Serialized loops (p-limit(1)) favor safety over throughput.
MySQL handles OLTP + some analytics-like queries together.
Multiple specialized schedulers increase control but also operational surface area.
Likely bottlenecks at scale:

Large transaction_logs scans during report windows.
Single-instance scheduler throughput limits.
Cross-table write contention during burst ingestion + scheduled jobs.
Scalable redesign options:

Introduce durable queue (Kafka/SQS/RabbitMQ) for job commands.
Split OLTP and read/report workloads (read replica or dedicated analytics store).
Partition/shard high-volume logs by time/platform.
Add idempotency keys and outbox/inbox patterns for stronger exactly-once semantics across boundaries.
Replace global in-memory job flags with persistent distributed locks.



18) 90-Second / 5-Minute / 15-Minute Storytelling Scripts
90-Second Version
“I owned a financial operations backend with two API surfaces and multiple scheduler workers. The core challenge was keeping balances consistent while supporting high-volume transaction ingestion and report exports. I designed around transaction-safe writes, derived daily/platform balances, and scheduled reconciliation jobs. I also optimized report query performance by evolving index strategy and query filtering paths, and reduced scheduler DB footprint by tuning connection pools. The system emphasizes operational safety, auditability, and controlled throughput.”

5-Minute Version
Context: financial ops backend, two APIs, PM2 multi-process runtime.
Architecture: management API for operators, platform API for external ingestion, scheduler workers for asynchronous computations.
Consistency design: transactional writes, derived balance tables, periodic reconciliation.
Async report design: status-driven report requests + scheduler/worker pipeline + Excel streaming upload.
Optimization examples: report-query/index evolution and scheduler pool tuning.
Tradeoffs: safe serialization vs throughput, in-memory orchestration simplicity vs durability.
15-Minute Version
Problem framing and business constraints (financial correctness over raw throughput).
Domain breakdown (auth/rbac, ingestion, settlement, reporting, reconciliation).
High-level architecture walkthrough with data/control flows.
Deep dive into ingestion consistency and batch error behavior.
Deep dive into daily balance and platform aggregate pipeline logic.
Deep dive into async report state machine and storage integration.
Deep dive into reconciliation locking and historical mismatch detection.
Optimization case studies with commit-backed evidence.
Limitations and next-step redesign for scale.
