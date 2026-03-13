
## Why Locks Exist

MVCC handles read-write concurrency through snapshots. But write-write concurrency still needs locks:

```
Transaction A and B both want to modify the same row
→ Without locks: both read the same value, both write, one overwrites the other
→ With locks: only one can proceed, the other waits
```

---

## Lock Types Overview

```
MySQL InnoDB Lock
├── Row-Level Lock
│   ├── Record Lock     ← locks a single index record
│   ├── Gap Lock        ← locks the gap between index records
│   └── Next-Key Lock   ← Record Lock + Gap Lock (left-open, right-closed)
│
├── Table-Level Lock
│   ├── IS Lock         ← Intent Shared
│   ├── IX Lock         ← Intent Exclusive
│   ├── S Lock          ← Shared (whole table)
│   └── X Lock          ← Exclusive (whole table)
│
└── Global Lock
    └── FTWRL           ← Flush Tables With Read Lock
```

---

## 1. Row-Level Locks

### Record Lock

Locks a **single index record**.

```
Index:
... | 10 | 20 | 30 | 40 | ...

Record Lock on id=20:
... | 10 | [20] | 30 | 40 | ...
           ↑
           locked, other transactions cannot modify this row
```

```sql
-- Triggers Record Lock (exact match on indexed column)
SELECT * FROM accounts WHERE id = 20 FOR UPDATE;
```

---

### Gap Lock

Locks the **gap between two index records**. Prevents INSERT into the gap.

```
Index:
... | 10 | 20 | 30 | 40 | ...

Gap Lock on (20, 30):
... | 10 | 20 | (/////) | 30 | 40 | ...
              ↑
              gap locked, cannot INSERT id=25 here
```

```sql
-- Triggers Gap Lock (range query)
SELECT * FROM accounts WHERE id > 20 AND id < 30 FOR UPDATE;
```

Key properties:

```
Gap Lock only prevents INSERT, not reads
Two transactions can hold the same Gap Lock simultaneously
→ Gap Locks do not conflict with each other
→ Gap Locks only conflict with INSERT operations
```

Left boundary rule:

```
Gap Lock left boundary = the previous existing index record

Index has: 10, 30, 40 (no id=20)
Range query hits id=30
→ Gap Lock is (10, 30], not (20, 30]
→ Left boundary goes back to the previous existing record

No records before id=30:
→ (-∞, 30]

No records after id=30:
→ (30, +∞)
```

---

### Next-Key Lock

**Record Lock + the Gap Lock to its left**. A left-open, right-closed interval.

```
Index:
... | 10 | 20 | 30 | 40 | ...

Next-Key Lock on id=30:
Locks (20, 30]
→ Gap (20, 30) cannot be inserted into
→ Record id=30 itself cannot be modified
```

MySQL Repeatable Read uses Next-Key Lock by default for range queries:

```sql
-- Locks (20, 30] and (30, 40]
SELECT * FROM accounts WHERE id > 20 AND id < 40 FOR UPDATE;
```

**Why Next-Key Lock prevents Phantom Read**

```
Transaction A:
SELECT FOR UPDATE WHERE amount > 100
→ finds 3 rows: id=20, 30, 40
→ Next-Key Lock covers: (10,20], (20,30], (30,40], (40,+∞)

Transaction B:
INSERT id=25, amount=200
→ wants to insert into gap (20, 30)
→ gap is locked by A
→ must wait for A to commit

Transaction A reads again → still 3 rows, no phantom ✅
```

**Exact match does NOT need Gap Lock:**

```sql
-- id=30 exact match → only Record Lock needed
-- No phantom read possible (phantom = new rows appearing, not modification)
SELECT * FROM accounts WHERE id = 30 FOR UPDATE;
```

---

## 2. Table-Level Locks

### Intent Locks (IS / IX)

Purpose: allow row locks and table locks to coexist **without scanning the entire table**.

```
Problem without intent locks:
Transaction A holds row locks on some rows
Transaction B wants to lock the whole table
→ B must scan every row to check for conflicts
→ Very expensive
```

Solution:

```
Before acquiring a row lock, first add an intent lock on the table:
Row S Lock → first add IS Lock on table
Row X Lock → first add IX Lock on table

Transaction B wanting a table lock:
→ Just checks if the table has IS or IX lock
→ No need to scan all rows
```

Compatibility matrix:

```
        IS    IX    S     X
IS      ✅    ✅    ✅    ❌
IX      ✅    ✅    ❌    ❌
S       ✅    ❌    ✅    ❌
X       ❌    ❌    ❌    ❌
```

Key rules:

```
IS + IS ✅  both want shared row locks, no conflict
IS + IX ✅  row-level conflicts handled by row locks, table level fine
IX + IX ✅  same as above
IS + S  ✅  both reading, no conflict
IX + S  ❌  one modifying rows, other locking whole table read-only
IX + X  ❌  one modifying rows, other locking whole table exclusively
X  + *  ❌  whole table exclusive, nothing else allowed
```

> **Intent locks always compatible with each other (IS/IX). Real conflicts handled at row level.**

---

### S Lock / X Lock (Table Level)

```sql
-- Table S Lock (read only)
LOCK TABLE accounts READ;

-- Table X Lock (exclusive)
LOCK TABLE accounts WRITE;
```

Rarely used directly. Usually triggered implicitly (e.g. DDL operations).

---

## 3. Global Lock

```sql
FLUSH TABLES WITH READ LOCK;  -- FTWRL
```

Locks the **entire database**. All tables become read-only:

```
After FTWRL:
├── All DML (INSERT, UPDATE, DELETE) blocked
├── All DDL (CREATE, ALTER) blocked
└── Only SELECT allowed
```

Use case: full database backup to ensure consistent snapshot.

Better alternative:

```sql
-- mysqldump with single-transaction flag
-- Uses MVCC snapshot read instead of FTWRL
-- Does not block other operations
mysqldump --single-transaction mydb
```

---

## 4. Locks and Index Relationship

**All InnoDB locks are applied on index records, not directly on rows.**

```
Query with index (exact match):
→ Record Lock on that index record only
→ Only 1 row locked

Query with index (range):
→ Next-Key Lock on matching index records + gaps
→ Limited rows locked

Query WITHOUT index:
→ MySQL scans entire table
→ Locks ALL index records
→ Equivalent to locking the whole table
→ Massive contention
```

---

## 5. Deadlock

### What is it

Two transactions waiting for each other's locks, forming a circular dependency:

```
Transaction A: lock id=1 → waiting for id=2
Transaction B: lock id=2 → waiting for id=1

Timeline:
A: acquires lock id=1
                    B: acquires lock id=2
A: waiting for id=2 (held by B)
                    B: waiting for id=1 (held by A)
→ Neither can proceed → Deadlock
```

### MySQL Detection

MySQL maintains a **Wait-For Graph** internally:

```
A → waits for → B
B → waits for → A
→ Circular dependency detected → Deadlock confirmed
→ MySQL picks a victim (smaller undo log)
→ Force rollback the victim
→ Other transaction acquires lock and continues
```

Error returned to application:

```
Error: Deadlock found when trying to get lock; try restarting transaction
```

### Solutions

**Solution 1: Consistent lock ordering (most fundamental)**

```js
// Always lock in ascending id order
const ids = [fromId, toId].sort((a, b) => a - b)

const t = await sequelize.transaction()
for (const id of ids) {
  await Account.findOne({
    where: { id },
    lock: true,
    transaction: t
  })
}
// Both transactions lock in the same order → no circular dependency
```

**Solution 2: Retry mechanism**

```js
const MAX_RETRIES = 3

const transferWithRetry = async (fromId, toId, amount, retries = 0) => {
  try {
    await transfer(fromId, toId, amount)
  } catch (error) {
    if (error.message.includes('Deadlock') && retries < MAX_RETRIES) {
      await new Promise(resolve => setTimeout(resolve, 50 * (retries + 1)))
      return transferWithRetry(fromId, toId, amount, retries + 1)
    }
    throw error
  }
}
```

**Solution 3: Shorten transaction duration**

```js
// ❌ Bad: external API call inside transaction, lock held for a long time
const t = await sequelize.transaction()
const account = await Account.findOne({ lock: true, transaction: t })
await callExternalAPI()  // slow, lock held during this
await account.update(..., { transaction: t })
await t.commit()

// ✅ Good: do slow work first, then open transaction
const apiResult = await callExternalAPI()  // outside transaction
const t = await sequelize.transaction()
const account = await Account.findOne({ lock: true, transaction: t })
await account.update(..., { transaction: t })
await t.commit()
// Lock held for minimum time
```

**Solution 4: SKIP LOCKED (job queue)**

```sql
-- Skip rows already locked by other transactions
SELECT * FROM jobs WHERE status = 'pending'
FOR UPDATE SKIP LOCKED;
```

```
Multiple workers competing for jobs:
→ Each worker skips locked rows
→ No waiting, no deadlock
→ Ideal for MS project report job queue
```

---

## 6. AWS RDS Lock Parameters

### `innodb_lock_wait_timeout`

Timeout for **general lock waiting** (not specific to deadlock):

```
Transaction A waiting for Transaction B to release a lock
Waiting exceeds innodb_lock_wait_timeout seconds
→ A gives up, throws timeout error
→ B is not affected

Default: 50 seconds
Recommended for financial systems: 5-10 seconds
→ Fail fast, let retry mechanism handle it
```

```sql
SHOW VARIABLES LIKE 'innodb_lock_wait_timeout';
SET innodb_lock_wait_timeout = 10;
```

### `innodb_deadlock_detect`

```
ON (default):
→ MySQL actively monitors Wait-For Graph
→ Detects circular dependency within milliseconds
→ Immediately rollbacks victim

OFF:
→ No active detection
→ Deadlock resolved only when innodb_lock_wait_timeout expires
→ Better performance under extreme concurrency (detection has overhead)
→ But deadlock takes much longer to resolve
```

Recommended: keep ON for financial systems.

Configure via **AWS RDS Parameter Group**:

```
RDS Console → Parameter Groups → find parameter → modify → apply to instance
```

---

## Prevention Checklist

```
1. Consistent lock ordering      ← most fundamental
2. Short transactions            ← minimize lock hold time
3. Index on WHERE clauses        ← narrow lock scope to Record Lock
4. Retry mechanism               ← handle unavoidable deadlocks
5. SKIP LOCKED for job queues    ← prevent worker contention
6. innodb_lock_wait_timeout = 5-10s ← fail fast
```

---

## Impact on MS Project

```
Daily settlement (multiple schedulers running concurrently):

Risk 1: Inconsistent lock ordering between schedulers
→ Deadlock between scheduler A and B
→ Solution: enforce consistent lock ordering across all schedulers

Risk 2: No index on WHERE clause in UPDATE
→ Locks entire transaction_logs table
→ All schedulers blocked
→ Solution: verify all UPDATE statements use indexed columns

Risk 3: Transaction too long (external API calls inside)
→ Lock held for seconds
→ High contention during settlement window
→ Solution: move external calls outside transaction
```

---

## Related Topics

- [[MVCC]] — How snapshot reads avoid locks entirely
- [[MySQL Transaction]] — ACID, isolation levels
- [[MySQL Index]] — Why indexes matter for lock scope
- [[MS Project]] — Scheduler design, settlement consistency