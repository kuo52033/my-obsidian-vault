### Multi-Version Concurrency Control

## What is it

MVCC is a concurrency control mechanism that allows **multiple versions of the same data to exist simultaneously**, so readers don't block writers and writers don't block readers.

> **Core idea: Instead of locking data when reading, give each transaction its own consistent snapshot of the database.**

---

## Why MVCC Exists

Without MVCC, the naive approach to concurrent reads/writes is locking:

```
Transaction A wants to read row X
Transaction B is writing row X
→ A must wait for B to finish
→ High contention, poor performance
```

With MVCC:

```
Transaction A wants to read row X
Transaction B is writing row X
→ A reads the old version of X from Undo Log
→ A and B run concurrently, no blocking
```

---

## The Two Problems MVCC Solves

```
✅ Write does not block Read
   Writer modifies data → Reader reads old snapshot, no waiting

✅ Read does not block Write
   Reader reads snapshot → Writer continues modifying, no waiting

❌ MVCC does NOT solve Write-Write conflicts
   Two transactions writing the same row → still need locks (SELECT FOR UPDATE)
```

---

## How MVCC Works Internally

### Hidden Columns on Every Row

InnoDB adds three hidden columns to every row:

|Column|Description|
|---|---|
|`DB_TRX_ID`|The transaction ID that last modified this row|
|`DB_ROLL_PTR`|Pointer to the previous version in Undo Log|
|`DB_ROW_ID`|Internal row ID (only if no primary key exists)|

```
Row in table:
┌─────────────┬──────────────┬──────────────┬──────────┐
│ balance=800 │ DB_TRX_ID=50 │ DB_ROLL_PTR──┼──→ Undo Log
└─────────────┴──────────────┴──────────────┴──────────┘
                                                  ↓
                                          balance=500 (old version)
                                            DB_TRX_ID=30
                                DB_ROLL_PTR──→ even older version...
```

### Undo Log — The Version Chain

Every time a row is modified, the old version is saved in the Undo Log. Rows form a **version chain** linked by `DB_ROLL_PTR`:

```
Current version (in table):   balance=800, trx_id=50
                                    ↓ (DB_ROLL_PTR)
Undo Log version 1:           balance=500, trx_id=30
                                    ↓ (DB_ROLL_PTR)
Undo Log version 2:           balance=200, trx_id=10
                                    ↓
                               (oldest version)
```

When a transaction needs to read an older version, it walks back through this chain until it finds the right version.

---

## Read View — How a Snapshot is Created

When a transaction performs a snapshot read, MySQL creates a **Read View** containing:

```
Read View:
├── m_ids        ← List of active (uncommitted) transaction IDs at this moment
├── min_trx_id   ← Smallest transaction ID in m_ids
├── max_trx_id   ← Next transaction ID to be assigned (not yet started)
└── creator_trx_id ← The current transaction's own ID
```

### Visibility Rules

For each row version, MySQL checks `DB_TRX_ID` against the Read View:

```
if DB_TRX_ID == creator_trx_id:
    → This transaction modified it → VISIBLE (can see own changes)

if DB_TRX_ID < min_trx_id:
    → Committed before snapshot was created → VISIBLE

if DB_TRX_ID >= max_trx_id:
    → Started after snapshot was created → NOT VISIBLE

if DB_TRX_ID in m_ids:
    → Active (uncommitted) when snapshot was created → NOT VISIBLE

→ If not visible, follow DB_ROLL_PTR to the previous version and check again
```

---

## Snapshot Read vs Current Read

### Snapshot Read (快照讀)

Reads from the MVCC snapshot — **no locks**.

```sql
SELECT * FROM accounts WHERE id = 1;
SELECT * FROM accounts;  -- regular SELECT
```

```
Transaction reads the snapshot version
→ Sees consistent data as of snapshot creation time
→ Not affected by other transactions' modifications
→ No locks acquired
```

### Current Read (當前讀)

Reads the **latest committed version** and acquires locks.

```sql
SELECT * FROM accounts WHERE id = 1 FOR UPDATE;        -- Exclusive lock (X Lock)
SELECT * FROM accounts WHERE id = 1 LOCK IN SHARE MODE; -- Shared lock (S Lock)
UPDATE accounts SET balance = 800 WHERE id = 1;
DELETE FROM accounts WHERE id = 1;
INSERT INTO accounts VALUES (...);
```

```
Transaction reads the most up-to-date data
→ Acquires lock on the row
→ Other transactions cannot modify this row until lock is released
→ Used when you need to modify data based on what you just read
```

### When to Use Which

```
Snapshot Read:
├── Just reading data for display
├── No need to modify based on result
└── Performance-sensitive reads

Current Read:
├── Reading before modifying (e.g. check balance before deducting)
├── Need latest value, not snapshot
└── Must prevent others from modifying concurrently
```

---

## MVCC Under Different Isolation Levels

MVCC only applies to **Read Committed** and **Repeatable Read**.

### Read Committed

**A new Read View is created for every SELECT.**

```
Transaction A starts

Transaction A: SELECT balance → Read View created → sees 500

Transaction B: UPDATE balance 500 → 800, COMMIT ✅

Transaction A: SELECT balance → New Read View created → sees 800
                                                         ↑
                                        New snapshot picks up B's commit
```

Result: Can always see the latest committed data, but same query may return different results within the same transaction → **Non-Repeatable Read**.

---

### Repeatable Read (MySQL Default)

**Read View is created ONCE at the start of the first SELECT.**

```
Transaction A starts

Transaction A: SELECT balance → Read View created → sees 500

Transaction B: UPDATE balance 500 → 800, COMMIT ✅

Transaction A: SELECT balance → SAME Read View → still sees 500
                                                   ↑
                                     Snapshot frozen at transaction start
```

Result: Same query always returns the same result within the transaction → **No Non-Repeatable Read**.

---

### Comparison

|                              | Read Committed | Repeatable Read                      |
| ---------------------------- | -------------- | ------------------------------------ |
| Read View creation           | Every SELECT   | Once at first SELECT                 |
| Sees other committed changes | ✅ Yes          | ❌ No (after snapshot)                |
| Non-Repeatable Read          | ❌ Possible     | ✅ Prevented                          |
| Phantom Read                 | ❌ Possible     | ✅ Mostly prevented (MVCC + Gap Lock) |

---

## MVCC vs Locking — Optimistic vs Pessimistic

|                                | Approach        | Description                                    |
| ------------------------------ | --------------- | ---------------------------------------------- |
| MVCC Snapshot Read             | Optimistic-like | No locks, assume no conflict, read old version |
| MVCC Current Read (FOR UPDATE) | Pessimistic     | Lock the row, prevent others from modifying    |
| Traditional locking            | Pessimistic     | Lock before read, others must wait             |

> **MVCC snapshot read is conceptually close to optimistic locking — it assumes conflicts are rare and avoids locking. But MVCC itself is a mechanism, not strictly equivalent to optimistic locking.**

---

## Phantom Read and Gap Lock

Repeatable Read + MVCC prevents most phantom reads for **snapshot reads**.

==But for **current reads**, phantom reads can still occur:==

```
Transaction A: SELECT FOR UPDATE WHERE amount > 100 → finds 3 rows, locks them

Transaction B: INSERT a new row with amount=200, COMMIT ✅

Transaction A: SELECT FOR UPDATE WHERE amount > 100 → now finds 4 rows
→ Phantom Read!
```

MySQL solves this with **Gap Lock** (Next-Key Lock):

```
Gap Lock locks the gaps between index values, not just the rows
→ Transaction B cannot INSERT into the gap
→ Phantom Read prevented even for current reads
```

---

## Practical Example — Financial System (MS Project)

### Wrong Approach (Snapshot Read — Race Condition)

```js
// ❌ Both transactions read balance=1000 from snapshot
// Both think there's enough balance
// Both deduct 800 → balance becomes -600

const account = await Account.findOne({ where: { id: 1 } })
// snapshot read — may be stale!

if (account.balance >= amount) {
  await account.update({ balance: account.balance - amount })
}
```

### Correct Approach (Current Read — Locked)

```js
// ✅ Only one transaction can hold the lock at a time
// Second transaction waits, reads updated balance after first commits
// Correctly prevents overdraft

const t = await sequelize.transaction()

try {
  const account = await Account.findOne({
    where: { id: 1 },
    lock: t.LOCK.UPDATE,   // SELECT FOR UPDATE → current read
    transaction: t
  })

  if (account.balance < amount) {
    throw new Error('Insufficient balance')
  }

  await account.update(
    { balance: account.balance - amount },
    { transaction: t }
  )

  await t.commit()
} catch (error) {
  await t.rollback()
  throw error
}
```

---

## Summary

```
MVCC
├── Mechanism: Multiple row versions stored in Undo Log
├── Read View: Snapshot of active transactions at a point in time
├── Snapshot Read: No lock, reads from snapshot (optimistic-like)
├── Current Read: Locks row, reads latest version (pessimistic)
│
├── Read Committed: New Read View per SELECT → sees latest commits
├── Repeatable Read: One Read View per transaction → consistent snapshot
│
├── Solves: Read-Write concurrency (no blocking)
└── Does NOT solve: Write-Write concurrency (still need locks)
```

---

## Related Topics

- [[ACID]] — Atomicity, Consistency, Isolation, Durability
- [[Transaction]] — How to use transactions in Sequelize
- [[Isolation Levels]] — Read Uncommitted, Read Committed, Repeatable Read, Serializable
-  [[Locking]] — Row locks, Gap locks, Next-Key locks
