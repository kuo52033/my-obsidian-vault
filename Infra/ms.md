title: "MS-System Backend System Design Case Study"
created: "2026-03-11"
language: "English"
audience: "Backend System Design Interviews"
repo: "/Users/guojunwei/ms-system"
scope: "Architecture-level, repo-verified"
tags: [system-design, backend, nodejs, mysql, redis, scheduler, interview]
MS-System Backend System Design Case Study
Evidence policy: This note uses repo-verifiable facts only.
Capacity numbers are explicitly marked as assumptions, not measured production metrics.

Table of Contents
Frontmatter + Context
System Scope & Goals
Functional Requirements
Non-Functional Requirements
Capacity Estimation
High-Level Architecture
Core Data Model & Storage Strategy
Deep Dive A: External Platform Transaction Ingestion
Deep Dive B: Daily Balance / Platform Balance Pipeline
Deep Dive C: Time-Statistic Async Report Generation
Deep Dive D: Balance-Difference Detection Job
Reliability, Consistency, Idempotency, Concurrency
Security & Access Control
Observability & Operations
Optimization Stories
Tradeoffs, Bottlenecks, and Scalable Redesign
Interview Q&A Cheat Sheet
90s / 5m / 15m Story Scripts
Appendix: Evidence Map
1) Frontmatter + Context
ms-system is a Node.js backend + management console for financial operations workflows: transaction ingestion, settlement/balance computation, reconciliation, reporting/export, and administrative controls.
It runs as multiple PM2 processes: API services and scheduler workers.

Evidence:
server/management.js
server/platform.js
pm2-processes/production.json

2) System Scope & Goals
Primary goals:

Accept transaction inputs from internal operators and external platforms.
Keep account/platform balances consistent over time.
Generate operational and statistical reports.
Provide auditability and controlled access.
Out of scope for this note:

Full UI behavior details.
Exhaustive endpoint-by-endpoint API docs.
Any claim requiring external metrics not available in repo.
3) Functional Requirements (Grouped by Domain)
Auth, identity, and role-based access
Password login + TOTP second step.
Session-based auth and role permission checks.
Platform-scoped data access controls.
Platform integration / ingestion
External platforms push transaction batches by platform name.
API validates platform + client IP.
Transaction normalization and per-record handling.
Transaction lifecycle management
Create/update/delete flows for deposit/payment/income-expenditure/transfer patterns.
Cross-platform transfer handling.
Serial number and type-based business constraints.
Balance and reconciliation
Daily balance calculation per bank account.
Platform aggregate balance calculation.
Balance-difference detection jobs over historical windows.
Reporting and exports
Management report generation and Excel exports.
Async time-statistic report generation and storage upload.
Queryable API logs and management logs.
Admin controls
IP whitelist management.
Platform and bank-account configuration.
Audit log generation for management operations.
Evidence:
server/routes/management-api/index.v1.js
server/routes/platform-api/platforms.js
server/lib/passport.js
server/services/daily-balance.js
server/services/balance-difference-job.js

4) Non-Functional Requirements
Consistency-first financial writes
Multi-step operations use DB transactions in services/stores.
Reconciliation tooling exists for mismatch detection.
Controlled background throughput
Scheduler workers often run with serialized processing (p-limit(1)).
Intended to protect DB and ensure deterministic processing order.
Operational resilience
Separate PM2 processes isolate API and scheduler failures.
Background jobs are restartable and status-driven.
Auditability
Request logs, API logs, and management logs are persisted.
Sensitive fields are scrubbed in request logging.
Security layers
TOTP + role permissions + IP restrictions + signature/timestamp checks for private API paths.
Evidence:
server/middlewares/log-request.js
server/services/api-log.js
server/services/management-log.js
server/route-hooks/common.js

5) Capacity Estimation (Assumption-driven)
Definitions:

P = active platforms
B = in-use bank accounts per platform (relevant categories)
T = externally ingested transaction records per platform per day
R = async time-stat report requests per day
B_eff = subset of bank accounts involved in balance-history snapshots
Core formulas:

External ingest rows/day: Rows_ingest ≈ P * T
Daily balance computations/day: Ops_daily_balance ≈ P * B
Bank-account history snapshots/day: Rows_snapshot ≈ 48 * P * B_eff (30-minute schedule)
Report jobs/day: Jobs_report ≈ R
Assumption Scenario A (Moderate):

P=20, B=50, T=3,000, B_eff=30, R=80
Rows_ingest ≈ 60,000/day
Ops_daily_balance ≈ 1,000/day
Rows_snapshot ≈ 28,800/day
Jobs_report ≈ 80/day
Assumption Scenario B (Peak):

P=60, B=120, T=10,000, B_eff=72, R=300
Rows_ingest ≈ 600,000/day
Ops_daily_balance ≈ 7,200/day
Rows_snapshot ≈ 207,360/day
Jobs_report ≈ 300/day
Notes:

These are estimation scaffolds for interviews.
No measured production latency/throughput is claimed.
Evidence for scheduling and job cadence:
server/cronjob-services/calculate-report-cronjob.js
server/cronjob-services/calculate-bank-account-balance-histories-cronjob.js

6) High-Level Architecture

optional
Management SPA(/management)
Management API Service(:3000)
External Platforms
Platform API Service(:3001)
MySQL
Redis
PM2 Scheduler Processes
Orchestrators + Workers(EventEmitter)
S3 (Report Files)
Google Drive Utility
Architecture characteristics:

Two HTTP API services: management and external platform integration.
Multiple independent scheduler processes for periodic jobs.
Shared MySQL + Redis.
In-process event orchestration (not a distributed queue).
Evidence:
server/management.js
server/platform.js
server/orchestration-services/index.js
server/event-services/index.js

7) Core Data Model & Storage Strategy
Key patterns:

transaction_logs as central ledger-like table
Denormalized fields for reporting (bankCategoryType, virtualCurrencyWallet).
Composite and covering indexes for heavy report queries.
Unique constraint for serial-number/type conflict prevention.
Derived balance tables
daily_balances per bank account/day.
platform_balances aggregate per platform/day.
Reconciliation entities
balance_difference_jobs + balance_difference_records.
Async reporting entities
time_statistic_reports with status lifecycle (HANDLING, SUCCESS, FAILED, NO_DATA).
Retention controls
TTL-style index setup for high-volume operational log tables.
Evidence:
server/schemas/mysql/transaction-log.js
server/services/daily-balance.js
server/services/platform-balance.js
server/stores/time-statistic-report.js
migrations/46-1.23.0.js

8) Deep Dive A: External Platform Transaction Ingestion
Flow:

External client calls POST /api/v1/platforms/name=:platformName/transactions.
Hooks validate request shape and resolve platform by name + client IP.
API log hook captures request/response metadata.
Service writes business records, updates balances, and stores error logs for invalid records.
Sequence (consistency view):


MySQL
Transaction Service
Hook Layer
Platform API
External Platform
MySQL
Transaction Service
Hook Layer
Platform API
External Platform
alt
[record-level business error]
[success]
loop
[each input record]
POST /api/v1/platforms/name=:platformName/transactions
validate + platform/IP checks
platformId/systemHandleHour
createTransactionLogsByPlatformIdAndRequestBody(...)
BEGIN
update bank_account balances/today counters
insert transaction_logs
insert transfer_logs(error details)
COMMIT
COMMIT
201 "ok" (batch level)
Failure modes:

Invalid platform/IP -> rejected.
Duplicate serial-like conflicts -> blocked by constraints/business checks.
Partial bad records in batch -> captured in transfer logs.
Evidence:
server/routes/platform-api/platforms.js
server/route-hooks/management/platform/create-transaction-logs-belong-to-platform-request/index.js
server/route-hooks/management/platform/common.js
server/route-handlers/management/platform/handle-create-transaction-logs-belong-to-platform-request.js
server/services/transaction-log.js
tests/server/routes/platform-api/platform.test.js

9) Deep Dive B: Daily Balance / Platform Balance Calculation Pipeline
Pipeline:

Cron triggers platform-data orchestrator by systemHandleHour (0/3/8) and monthly residue handling.
Orchestrator emits command event with requestId.
Worker serially processes platforms and bank accounts.
For each bank account/day: yesterday + transactions + residue => daily_balance.
Platform aggregate is computed from daily balances and residue totals.
Design choices:

p-limit(1) serialization reduces DB burst pressure.
platform_balance create handles unique conflict as idempotent guard.
Same business formula reused in recalculation scripts.
Evidence:
server/cronjob-services/calculate-platform-data-cronjob.js
server/event-services/calculate-platform-data-worker.js
server/services/daily-balance.js
server/services/platform-balance.js
ms-recalcu.js

10) Deep Dive C: Time-Statistic Async Report Generation
Flow:

Management API creates a report request row (HANDLING) with filter parameters.
Scheduler runs every minute.
Guard flag prevents overlapping generation waves.
Worker reads HANDLING reports, processes one-by-one (p-limit(1)), generates Excel stream, uploads to S3, updates status.

No
Yes
Yes
No
Create time-stat reportrequest
Insert status=HANDLING
Cron every minute
IS_GENERATE_REPORT_FINISHED
Skip tick
Emit generate command
Worker reads HANDLINGrows
Generate Excel stream
Upload to S3
Has data?
Update status=SUCCESS,completedAt
Update status=NO_DATA
On error: status=FAILED +errorMessage
Set flag true
Failure handling:

Per-report failures are persisted with error messages.
Job loop continues without crashing whole scheduler process.
Evidence:
server/event-services/generate-time-statistic-report-worker.js
server/orchestration-services/generate-time-statistic-report-orchestrator.js
server/lib/excel-generator/deposit-time-statistics-report.js
server/lib/excel-generator/payment-time-statistics-report.js
server/stores/time-statistic-report.js

11) Deep Dive D: Balance-Difference Detection & Reconciliation Job
Flow:

API creates a WAITING reconciliation job (guarded against duplicates/in-flight jobs).
Scheduler tick emits job command every minute.
Worker picks one WAITING job using row lock, sets PROCESSING.
For each platform/account, replays expected daily balances over ~1 month window and compares against actual.
Writes mismatch records, marks job COMPLETED or FAILED.
Key consistency point:

SELECT ... FOR UPDATE-style lock behavior ensures single ownership of the active job row.
Evidence:
server/services/balance-difference-job.js
server/event-services/calculate-balance-difference-worker.js
server/cronjob-services/calculate-balance-difference-cronjob.js

12) Reliability, Consistency, Idempotency, and Concurrency Controls
Financial multi-step writes use DB transactions in service layer.
Unique indexes reduce duplicate insertion risk for serial-based data.
Reconciliation jobs use locked state transitions (WAITING -> PROCESSING -> COMPLETED/FAILED).
Scheduler workers often serialize heavy loops with p-limit(1).
Report generation uses global overlap guard (IS_GENERATE_REPORT_FINISHED).
Process isolation via PM2 decouples API and background workload failure domains.
Evidence:
server/services/transaction-log.js
server/schemas/mysql/transaction-log.js
server/services/balance-difference-job.js
pm2-processes/production.json

13) Security & Access Control
Password login + guest-session TOTP completion flow.
Permission checks for role-based operations.
IP whitelist controls for management access and platform API binding.
Signature + timestamp validation for private API routes.
Request log sanitization for sensitive fields.
Evidence:
server/lib/passport.js
server/route-hooks/common.js
server/middlewares/validate-request-ip.js
server/services/ip-whitelist.js
server/routes/private-api/index.v1.js

Confidentiality note:

Do not present raw credentials/keys from config files in interviews.
Discuss mechanism, not secret values.
14) Observability & Operations
Request-level logging includes status, latency, method, URL, IP, request ID.
API logs persist request/response snapshots for platform-facing interfaces.
Management logs capture operator-side changes.
/health endpoints exist on API services.
PM2 process list separates concerns and simplifies restart boundaries.
Evidence:
server/middlewares/log-request.js
server/services/api-log.js
server/management.js
server/platform.js
pm2-processes/production.json

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
17) Interview Q&A Cheat Sheet
Q: Why separate management API and platform API?
A: Different trust boundaries, clients, and traffic patterns. Platform API is integration-facing; management API is operator-facing.

Q: How do you protect financial consistency?
A: DB transactions, strict status transitions, reconciliation jobs, and uniqueness constraints.

Q: How do you avoid duplicate external transactions?
A: Serial/type/platform uniqueness and business validations in service hooks.

Q: What does your async reporting architecture look like?
A: Request row (HANDLING) + scheduler + worker + storage upload + status machine.

Q: Why use serialized background processing?
A: To control DB pressure and preserve deterministic behavior in sensitive financial computations.

Q: How do you monitor platform integrations?
A: API logs, request logs, transfer error logs, and management logs.

Q: What optimization are you most confident discussing?
A: Time-stat query/index evolution (8ee6fbd3, 6d8cbf5f) and scheduler connection pool tuning (5eb93a4e).

Q: Biggest limitation today?
A: In-process event orchestration lacks durable queue guarantees.

Q: If traffic triples, first changes?
A: Queue-backed jobs, read/write workload split, and partition strategy for transaction_logs.

Q: How do you handle security for internal and external APIs differently?
A: Internal: session + TOTP + RBAC + whitelist. External/private paths: platform/IP checks + signature/timestamp validation.

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
19) Appendix: Evidence Map
Topic	Evidence
Management API pipeline	server/management.js
Platform API pipeline	server/platform.js
PM2 process split	pm2-processes/production.json
Scheduler entrypoints	bin/calculate-platform-data-scheduler.js, bin/calculate-report-scheduler.js, bin/calculate-balance-difference-scheduler.js, bin/generate-time-statistic-report-scheduler.js
Orchestrators	server/orchestration-services
Workers	server/event-services
Ingestion route	server/routes/platform-api/platforms.js
Ingestion service	server/services/transaction-log.js
Daily balance logic	server/services/daily-balance.js
Platform balance logic	server/services/platform-balance.js
Reconciliation job	server/services/balance-difference-job.js
Time-stat report worker	server/event-services/generate-time-statistic-report-worker.js
Excel generators	server/lib/excel-generator
Query/index implementation	server/stores/transaction-log.js, server/schemas/mysql/transaction-log.js
Index migrations	migrations/52-1.29.3.js, migrations/53-1.29.4.js
TTL retention rollout	migrations/46-1.23.0.js
DB pool tuning	server/lib/database.js
Security hooks	server/route-hooks/common.js, server/lib/passport.js, server/services/ip-whitelist.js
Test evidence	tests/server/routes/platform-api/platform.test.js, tests/server/routes/management-api
Commit references	8ee6fbd3, 6d8cbf5f, 5eb93a4e
