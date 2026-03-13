
## Overview

project scheduler architecture uses three layers:

```
Cron Job (time trigger)
    ↓
Orchestrator (coordination + request tracking)
    ↓
Worker (business logic)
```

Decoupled via in-process EventEmitter. Lightweight, no additional infrastructure required.

---

## Cron Job

```
┌─────────── minute (0-59)
│ ┌───────── hour (0-23)
│ │ ┌─────── day (1-31)
│ │ │ ┌───── month (1-12)
│ │ │ │ ┌─── weekday (0-6, 0=Sunday)
│ │ │ │ │
* * * * *
```

Common examples used in MS project:

```
0 0 * * *      daily at 00:00       ← daily settlement
*/30 * * * *   every 30 minutes     ← record bank balances
0 * * * *      every hour
```

### Node.js Usage

```js
const cron = require('node-cron')

cron.schedule('0 0 * * *', async () => {
  await orchestrator.emit('command:settlement', { date: new Date() })
})
```

---

## Orchestration Pattern

### Why This Pattern

Without orchestration, cron job calls worker directly:

```js
// ❌ Tightly coupled
cron.schedule('0 0 * * *', async () => {
  await settleAllBanks()  // cron knows implementation details
})
```

Problems:

- Cron job knows worker implementation details
- Hard to replace or add workers
- Hard to test (must mock entire cron)
- No place to insert orchestration logic

With EventEmitter:

```
Cron Job → emit event → does not know who handles it
Orchestrator → listens → coordinates
Worker → listens → executes

Each layer only knows its own responsibility
No direct dependencies between layers
```

### Three Layers

**Layer 1: Cron Job — time trigger only**

```js
cron.schedule('0 0 * * *', () => {
  orchestrator.emit('command:settlement', { date: new Date() })
  // job ends here, does not care about result
})
```

**Layer 2: Orchestrator — coordination + request tracking**

```js
orchestrator.on('command:settlement', async (payload) => {
  // Request tracking: record job started
  const jobId = await JobRecord.create({
    type: 'settlement',
    status: 'processing',
    startedAt: new Date()
  })

  try {
    orchestrator.emit('job:settlement', { ...payload, jobId })

    orchestrator.once(`reply:settlement:${jobId}`, async (result) => {
      if (result.success) {
        await JobRecord.update(
          { status: 'completed', completedAt: new Date() },
          { where: { id: jobId } }
        )
      } else {
        await JobRecord.update(
          { status: 'failed', error: result.error },
          { where: { id: jobId } }
        )
      }
    })
  } catch (error) {
    await JobRecord.update({ status: 'failed' }, { where: { id: jobId } })
  }
})
```

**Layer 3: Worker — business logic only**

```js
orchestrator.on('job:settlement', async ({ jobId, date }) => {
  try {
    await settleAllBanks(date)
    await calculateDailyBalances(date)

    orchestrator.emit(`reply:settlement:${jobId}`, { success: true })
  } catch (error) {
    orchestrator.emit(`reply:settlement:${jobId}`, {
      success: false,
      error: error.message
    })
  }
})
```

### Request Tracking Value

Every job has a record in the database:

```js
{
  id: 1,
  type: 'settlement',
  status: 'processing' | 'completed' | 'failed',
  startedAt: '2024-01-01 00:00:00',
  completedAt: '2024-01-01 00:03:22',
  error: null
}
```

Enables:

- Verify daily settlement succeeded
- Know which step failed when it does
- Monitor how long settlement takes
- Manually re-run failed jobs

---

## Serial Execution with p-limit(1)

### Why Serial over Parallel

30 banks settled in parallel causes:

- Write contention — all updating transaction_logs simultaneously, heavy lock competition, risk of Deadlock
- Resource exhaustion — DB connection pool consumed, normal API requests blocked
- Hard to recover — if one fails mid-way, others already partially written, inconsistent state

Serial execution (one bank at a time):

- Clear error boundaries — Bank A fails, B and C haven't started yet
- Controlled DB pressure — only one settlement reading/writing at a time
- Predictable state — each settlement completes fully before the next reads data

### Implementation

```js
const pLimit = require('p-limit')
const limit = pLimit(1)  // concurrency = 1, serial execution

const settleBanks = async (banks) => {
  const tasks = banks.map(bank => limit(() => settleBank(bank)))
  await Promise.all(tasks)
  // Despite Promise.all, only 1 task runs at a time due to p-limit(1)
}
```

Advantage: changing to concurrency 2 or 3 later requires changing only one number.

### Trade-off

30 banks × 1 second each = 30 seconds total. Parallel would be faster, but:

- Financial systems prioritize correctness over speed
- Settlement runs at midnight when no users are active
- 30 seconds is completely acceptable

---

## High Availability — Solving SPOF

### The Problem

Single Scheduler instance:

```
PM2 auto-restarts after crash, but restart takes time
If crash happens exactly at 00:00
→ Restart completes at 00:00:30
→ Cron job missed the trigger
→ Settlement does not run until tomorrow
```

### Solution: Multiple Schedulers + Distributed Lock

Deploy 3 Scheduler instances, all competing for a Redis lock:

```
00:00 — all 3 Schedulers trigger simultaneously

Scheduler 1 ─┐
Scheduler 2 ─┼─ compete for Redis lock (SET NX is atomic)
Scheduler 3 ─┘

Scheduler 1 acquires lock → executes settlement
Scheduler 2 fails → RedisLockFailedError → exits
Scheduler 3 fails → RedisLockFailedError → exits
```

### Distributed Lock Implementation

```js
async function dataCacheRedisWithLock(key, mainLogic, { ttl = REDIS_LOCK_TTL } = {}) {
  const redisClient = getDataCacheRedis()
  const lockKey = `lock:${key}`
  const lockValue = crypto.randomBytes(16).toString('hex')  // unique per instance
  let lockRequired = false

  try {
    const result = await redisClient.set(lockKey, lockValue, { NX: true, EX: ttl })
    lockRequired = (result === 'OK')

    if (!lockRequired) {
      throw new RedisLockFailedError()  // fail fast, do not wait
    }

    return await mainLogic()
  } finally {
    if (lockRequired) {
      // Lua script: atomic GET + DEL, only delete own lock
      const luaScript = `
        if redis.call("GET", KEYS[1]) == ARGV[1] then
          return redis.call("DEL", KEYS[1])
        else
          return 0
        end
      `
      await redisClient.eval(luaScript, { keys: [lockKey], arguments: [lockValue] })
    }
  }
}
```

### Key Design Decisions

**Unique lockValue per instance:**

Without unique value:

```
Scheduler A holds lock, TTL expires (execution took too long)
Scheduler B acquires new lock
Scheduler A finishes, DEL lockKey → deletes B's lock
Scheduler C acquires lock → A and C run simultaneously 💥
```

With unique lockValue, Lua script checks before deleting:

```
GET lockKey → if value matches my lockValue → DEL
Otherwise → skip, do not delete someone else's lock
```

**Why Lua Script for release:**

GET + DEL cannot be done separately:

```js
// ❌ Race condition between GET and DEL
const value = await redis.get(lockKey)
if (value === lockValue) {
  // another process could acquire lock here
  await redis.del(lockKey)  // might delete their lock
}
```

Lua script executes atomically in Redis — GET and DEL cannot be interrupted.

**Fail Fast on lock failure:**

```js
if (!lockRequired) {
  throw new RedisLockFailedError()  // do not wait, do not retry
}
```

Another instance is already running — no need to wait. Next cron trigger will try again.

### TTL Strategy

```
TTL too short:
Settlement still running, lock expires
→ Another Scheduler acquires lock
→ Two running simultaneously → duplicate settlement 💥

TTL too long:
Scheduler crashes, lock not released
→ Must wait for TTL expiry before retry
→ Settlement blocked for a long time

Recommended: TTL = 2-3x expected execution time
+ finally block ensures immediate release on normal completion
```

### What This Solves

```
SPOF resolved:
Scheduler 1 crashes before acquiring lock
→ Lock not held
→ Scheduler 2 or 3 acquires lock on next trigger
→ Settlement still runs ✅

Duplicate execution prevented:
SET NX guarantees only one succeeds
→ Three trigger simultaneously, only one executes ✅

Crash recovery:
Scheduler 1 crashes mid-execution
→ finally did not run, lock not released
→ Wait for TTL expiry
→ Scheduler 2 or 3 acquires lock and re-runs ✅
```

---

## Trade-offs

||Pros|Cons|
|---|---|---|
|EventEmitter|Lightweight, no extra infrastructure, clear layer separation|In-process only, no persistence across crashes|
|p-limit(1) serial|Safe, clear error boundaries, no Deadlock risk|Slower than parallel|
|Distributed lock|Solves SPOF, prevents duplicate execution|Depends on Redis availability|
|Request tracking|Full audit trail, easy to detect failures|Extra DB writes per job|

### Known Limitation

In-process EventEmitter has no persistence:

```
Process crash mid-execution
→ All in-flight events lost
→ Only evidence is job record stuck at 'processing'
→ Must manually identify and re-run failed jobs
```

Mitigation strategies:

- Idempotency design — re-running produces same result
- Checkpoint pattern — save progress to DB, resume from last completed step
- PM2 auto-restart — minimizes downtime window

### Upgrade Path

```
Current: EventEmitter (in-process, no persistence)
    ↓ need persistence + cross-process
BullMQ (Redis-backed, auto-retry, stalled job detection)
    ↓ need cross-machine + high availability
Kafka / SQS (distributed, durable, scalable)
```

---

## Interview Answer

「我們的 Scheduler 採用三層 Orchestration Pattern：Cron Job 只負責時間觸發，Orchestrator 用 EventEmitter 協調並做 request tracking，Worker 只管業務邏輯。三層之間完全解耦，職責清晰。

結算用 p-limit(1) 串行執行，確保每個銀行的錯誤邊界清晰，避免並行寫入造成的 Deadlock 和資料不一致。

為了解決 SPOF，我們部署三個 Scheduler instance，每次觸發時同時搶 Redis 分散式鎖，只有搶到鎖的才執行。鎖的釋放用 Lua Script 確保原子性，避免刪到別人的鎖。

這個設計的已知限制是 EventEmitter 沒有持久化，process crash 後 in-flight job 需要手動補跑。如果未來需要更強的保證，會考慮換成 BullMQ。」

---

## Related Topics

- [[MySQL Lock]] — Deadlock prevention in serial settlement
- [[Redis]] — Distributed lock, SET NX atomicity
- [[MS Project]] — Daily settlement flow, report generation
- [[Idempotency]] — Ensuring re-runs produce correct results