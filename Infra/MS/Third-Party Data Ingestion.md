
## Overview

MS project receives transaction data from ~30 third-party integrations. Two-layer security protects the ingestion endpoint.

```
Third-party sends request
    ↓
Layer 1: IP Whitelist (network layer)
    ↓
Layer 2a: Decrypt parameters (AES-256-CBC)
Layer 2b: Verify signature (HMAC-SHA256)
    ↓
Timestamp validation (Replay Attack prevention)
    ↓
Business logic + Idempotency check
    ↓
Write transaction + update balance
```

---

## Layer 1: IP Whitelist

Only allow requests from known third-party IP addresses.

```js
const WHITELIST = ['1.2.3.4', '5.6.7.8']

const ipWhitelistMiddleware = (req, res, next) => {
  const clientIp = req.headers['x-forwarded-for'] || req.socket.remoteAddress
  if (!WHITELIST.includes(clientIp)) {
    return res.status(403).json({ error: 'IP not allowed' })
  }
  next()
}
```

Value of this layer:

```
Even if attacker obtains key and iv
→ IP not in whitelist
→ Request blocked immediately
→ No chance to attempt decryption
```


---

## Layer 2a: Parameter Encryption (AES-256-CBC)

### Why Encrypt Parameters

HTTPS encrypts transport, but server logs, proxies, and middleware may log plaintext parameters. AES encryption ensures sensitive financial data (amounts, account numbers) is never exposed in plaintext.

### AES Fundamentals

AES splits data into ==16-byte blocks== before encrypting.

Example with payload `{"uniqueId":"TXN-001","amount":1000,"bankCode":"ABC"}`:

```
Block 1: {"uniqueId":"TXN
Block 2: -001","amount":1
Block 3: 000,"bankCode":"
Block 4: ABC"}
```

The block structure is why the encryption mode matters significantly.

### Encryption Modes Compared

**ECB (Electronic Codebook) — never use**

Each block encrypted independently. Identical blocks produce identical ciphertext.

```
TXN-001 encrypted:
Block 1: e73851783ade7064...  ← same!
Block 2: d5c4216f1e44f3f8...
Block 3: 8b91aeeaa7b2c42f...  ← same!
Block 4: dca4b4a33cbd725e...  ← same!

TXN-002 encrypted (only uniqueId differs):
Block 1: e73851783ade7064...  ← same!
Block 2: d77e8912d503a706...  ← different (where uniqueId differs)
Block 3: 8b91aeeaa7b2c42f...  ← same!
Block 4: dca4b4a33cbd725e...  ← same!
```

Attacker can see without decrypting: "these two transactions have identical amounts and bank codes." Pattern leakage makes ECB completely unsuitable for financial data.

**CBC (Cipher Block Chaining) — current implementation**

Each block XOR with previous block's ciphertext before encrypting. First block XORed with IV.

```
Block 1 = AES_encrypt(plaintext_block1 XOR IV)
Block 2 = AES_encrypt(plaintext_block2 XOR block1_ciphertext)
Block 3 = AES_encrypt(plaintext_block3 XOR block2_ciphertext)
...
```

Fixed IV problem:

```
Encrypting TXN-001 twice with fixed IV (all zeros):
First:  e73851... 4ee3b0... fce050... 3c0c2a...
Second: e73851... 4ee3b0... fce050... 3c0c2a...  ← identical
```

Random IV solution:

```
Fixed IV result:  e73851783ade7064...
Random IV result: 798b27ae2a3ec6cb...  ← completely different

Same plaintext + different IV → completely different ciphertext ✅
```

CBC limitations:

- Requires padding (plaintext must be multiple of 16 bytes)
- No built-in integrity verification → must use HMAC separately
- Sequential processing, cannot parallelize
- IV must be random, fixed IV leaks patterns

**GCM (Galois/Counter Mode) — modern alternative**

Authenticated Encryption with Associated Data (AEAD): encryption + integrity verification in one step.

```
Encrypting same data twice with GCM:
First:  IV=528bbd3f...  ciphertext=0bbbbd91...  authTag=506c96fc...
Second: IV=a3f91c2d...  ciphertext=7e4ac012...  authTag=3b8f21aa...
← completely different every time ✅
```

Tamper detection:

```
Original ciphertext: 0bbbbd91dde4b0639aa0e62536fcbaa0...
Tampered ciphertext: 0bbbbd91dde4b0639aa0ffff36fcbaa0...

Decryption attempt → Error: Unsupported state or unable to authenticate data
GCM detects any modification and refuses to decrypt ✅
```

CBC without HMAC tamper detection:

```
If tampered position happens to produce valid padding
→ CBC decrypts successfully but returns corrupted data
→ Application cannot tell data was tampered
→ This is why CBC requires HMAC as a separate step
```

Mode comparison:

|                     | ECB       | CBC                     | GCM                           |
| ------------------- | --------- | ----------------------- | ----------------------------- |
| Pattern leakage     | ❌ severe  | ✅ none (with random IV) | ✅ none                        |
| Built-in integrity  | ❌         | ❌ needs HMAC            | ✅ AuthTag                     |
| Parallel processing | ✅         | ❌ sequential            | ✅                             |
| Padding required    | ✅         | ✅                       | ❌                             |
| IV reuse risk       | N/A       | low                     | high (critical vulnerability) |
| Maturity            | very high | very high               | high                          |

Current implementation uses CBC + HMAC (Encrypt-then-MAC pattern), which is equivalent in security to GCM but implemented in two separate steps.

---

## Layer 2b: Signature Verification (HMAC-SHA256)

### Why Signature is Needed

Encryption alone is not enough:

```
Encryption: ensures data cannot be read
Signature:  ensures data was not tampered with
            ensures request came from a legitimate third-party holding the key
```

### SHA256 vs HMAC-SHA256

SHA256 is a one-way hash function:

```
SHA256(data) → fixed 256-bit hash
→ cannot reverse hash back to original data
→ any change to data produces completely different hash
```

Problem with plain SHA256:

```
Attacker knows you use SHA256
→ attacker can compute SHA256 of any forged data
→ attacker forges both data and hash
→ server cannot distinguish legitimate from forged
```

HMAC incorporates a secret key into the hash:

```
HMAC-SHA256(key, message)
→ without the key, cannot produce a valid HMAC
→ attacker cannot forge signature without the key
```

### Signature Construction

```
signature = HMAC-SHA256(key, encryptedParams + timestamp) → hex
```

### Server Verification

```js
const verifySignature = (encryptedParams, timestamp, receivedSignature, key) => {
  const payload = encryptedParams + timestamp
  const expectedSignature = crypto
    .createHmac('sha256', Buffer.from(key, 'hex'))
    .update(payload)
    .digest('hex')

  // timingSafeEqual prevents timing attacks
  return crypto.timingSafeEqual(
    Buffer.from(receivedSignature, 'hex'),
    Buffer.from(expectedSignature, 'hex')
  )
}
```

Why `timingSafeEqual` instead of `===`:

```
String comparison (===) returns early on first mismatch
→ comparing 'aabbcc' vs 'aabbff' takes longer than 'aabbcc' vs 'ffffff'
→ attacker can measure response time to guess signature byte by byte
→ Timing Attack

timingSafeEqual always takes the same time regardless of where mismatch occurs
→ no timing information leaked
```

### Timestamp: Replay Attack Prevention

```
Without timestamp:
Attacker intercepts a legitimate request
→ resends the same request
→ server processes it again → duplicate transaction

With timestamp:
Server checks if timestamp is within acceptable window (e.g. ±5 minutes)
→ expired requests rejected
→ intercepted request becomes useless after 5 minutes
```

```js
const isTimestampValid = (timestamp) => {
  const now = Date.now()
  const diff = Math.abs(now - parseInt(timestamp))
  return diff < 5 * 60 * 1000  // valid within 5 minutes
}
```

### HMAC vs Digital Signature (RSA/ECC)

||HMAC-SHA256|RSA/ECC Signature|
|---|---|---|
|Key type|Symmetric (both parties share same key)|Asymmetric (private key signs, public key verifies)|
|Speed|Very fast|Slow|
|Non-repudiation|❌ both parties can produce HMAC|✅ only private key holder can sign|
|Use case|Trusted system-to-system communication|Legal/audit scenarios|

HMAC is appropriate for MS project: third-parties are pre-vetted and keys are exchanged in advance. Digital signatures would be needed if legal non-repudiation were required.

---

## Complete Request Handler

```js
const handleThirdPartyRequest = async (req, res) => {
  const { encryptedParams, timestamp, signature } = req.body
  const { key, iv } = getThirdPartyCredentials(req)  // per-third-party credentials

  // Step 1: validate timestamp (Replay Attack prevention)
  if (!isTimestampValid(timestamp)) {
    return res.status(401).json({ error: 'Request expired' })
  }

  // Step 2: verify signature (integrity + authentication)
  if (!verifySignature(encryptedParams, timestamp, signature, key)) {
    return res.status(401).json({ error: 'Invalid signature' })
  }

  // Step 3: decrypt parameters
  const params = decryptParams(encryptedParams, key, iv)

  // Step 4: idempotency check + business logic
  await processTransaction(params)

  res.json({ success: true })
}
```

---

## Idempotency

Third-party includes a `uniqueId` in every request payload. Database has a UNIQUE constraint on the `uniqueId` column.

```js
try {
  await Transaction.create({
    uniqueId: params.uniqueId,
    amount: params.amount,
    // ...
  })
} catch (error) {
  if (error.name === 'SequelizeUniqueConstraintError') {
    // duplicate transaction, skip silently
    return res.json({ status: 'duplicate', message: 'Transaction already processed' })
  }
  throw error
}
```

Why UNIQUE constraint is safer than SELECT then INSERT:

```
SELECT then INSERT:
Transaction A: SELECT → uniqueId not found
Transaction B: SELECT → uniqueId not found (same time)
Transaction A: INSERT → success
Transaction B: INSERT → duplicate! race condition 💥

UNIQUE constraint:
Both attempt INSERT simultaneously
Database atomically allows only one
The other receives a constraint error
→ no race condition possible ✅
```

---

## Balance Update Concurrency

Two mechanisms prevent Lost Update on balance:

```
Without protection:
Transaction A reads balance = 1000, plans to add 100
Transaction B reads balance = 1000, plans to add 200 (simultaneously)
Transaction A writes 1100
Transaction B writes 1200  ← overwrites A's result
Correct answer: 1300, actual: 1200 → 100 lost 💥
```

**Distributed lock (Redis):** only one transaction can modify a given bank's balance at a time.

**Serial execution (p-limit(1)):** transactions for the same bank processed one at a time.

See [[CronJob_PM2_Orchestration]] for distributed lock implementation details.

---

## Key Management

```
Never hardcode key/iv in source code
→ store in environment variables or AWS Secrets Manager
→ each third-party has its own independent key/iv pair
→ key rotation: periodically issue new keys, overlap period for migration
```

---

## Security Layer Summary

```
Layer 1: IP Whitelist
→ network-level, blocks unknown sources before any processing

Layer 2a: AES-256-CBC encryption
→ protects data confidentiality
→ sensitive fields never appear in plaintext in logs or proxies

Layer 2b: HMAC-SHA256 signature
→ protects data integrity (tamper detection)
→ authenticates request origin (only key holder can produce valid signature)
→ timestamp prevents Replay Attacks
→ timingSafeEqual prevents Timing Attacks

Application layer: Idempotency + distributed lock
→ prevents duplicate transactions
→ prevents balance race conditions
```

Two layers are complementary, not redundant:

```
IP Whitelist: fast rejection at network layer, reduces attack surface
AES + HMAC:   protects against compromised network layer or IP spoofing
```

---

## Potential Interview Questions

**Q: Why CBC instead of GCM?**

CBC + HMAC (Encrypt-then-MAC) is security-equivalent to GCM, just implemented in two steps. GCM is the more modern choice — combines encryption and integrity verification in one step. Switching requires renegotiating the interface with all 30 third parties.

**Q: What if a third-party's key is compromised?**

Each third-party has an independent key/iv pair. Compromise of one key only affects that third-party's transactions. Rotate the compromised key immediately via AWS Secrets Manager. IP Whitelist provides additional protection even with a leaked key.

**Q: How do you handle clock skew for timestamp validation?**

Allow ±5 minute window to account for clock differences between systems. Too tight a window causes false rejections; too loose increases Replay Attack window. 5 minutes is the industry standard (same as AWS Signature v4).

---

## Interview Answer

「我們設計了兩層防護接收第三方資料。第一層是 IP Whitelist，只允許已知的第三方 IP 發送請求，在網路層直接擋掉未知來源。第二層是應用層的加密和簽章，參數用 AES-256-CBC 加密，signature 用加密後的參數加上 timestamp 做 HMAC-SHA256。Server 端重新計算 signature 來驗證資料完整性和請求來源。Timestamp 防止 Replay Attack，timingSafeEqual 防止 Timing Attack。

交易的冪等性靠資料庫的 UNIQUE constraint 保證，重複的 uniqueId 直接觸發 constraint error，比 SELECT 再 INSERT 更安全，沒有 race condition。

餘額更新用 Redis 分散式鎖加上串行執行，確保同一時間只有一筆交易在修改同一個銀行的餘額，防止 Lost Update。」

---

## Related Topics

- [[MySQL Lock]] — SELECT FOR UPDATE, Lost Update prevention
- [[CronJob_PM2_Orchestration]] — Distributed lock implementation
- [[Redis]] — Distributed lock, SET NX atomicity
- [[MS Project]] — Overall system architecture