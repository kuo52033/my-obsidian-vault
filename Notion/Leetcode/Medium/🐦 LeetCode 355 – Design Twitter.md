---
notion-id: 3035a6e2-1812-80a3-8183-e451ce83c018
---
## 題目核心

設計一個簡化版 Twitter，支援：

- 發文（postTweet）
- 追蹤 / 取消追蹤（follow / unfollow）
- 取得最新 10 則貼文（getNewsFeed）

限制重點：

- 貼文需依「時間由新到舊」
- 只需要 **Top 10**
- 使用者追蹤人數不固定

---

## 解題核心模型（一定要寫在筆記最前面）

> **這題本質是：
從「多個已排序的時間序列」中，
取出最新的 K 筆資料（K = 10）**

👉 標準解法：**k-way merge + heap**

---

## 為什麼不能把所有 tweet 都丟進 heap？

假設：

- 追蹤 1000 人
- 每人 1000 則 tweet
→ 100 萬筆資料

但題目只要：

```plain text
最新 10 則
```

👉 正確策略：

- 每個人「同一時間只保留 1 則候選 tweet」
- 誰被取走，再補他「下一則舊的」

---

## 資料結構設計（為什麼這樣放）

```python
self.time# 全域遞增時間戳self.tweets# userId -> [(time, tweetId), ...]self.following# followerId -> set(followeeId)
```

### 設計理由

- `time`：避免實際比較時間字串
- `tweets[userId]`：
    - append 即可
    - 天然時間排序
- `following` 用 set：
    - O(1) 查找
    - 避免重複追蹤

---

## Heap 設計（這題的靈魂）

### Heap tuple 結構

```python
(-time, tweetId, userId, index)
```

| 欄位 | 意義 |
| --- | --- |
| `-time` | Python 是 min-heap，用負號模擬 max-heap |
| `tweetId` | 最終要回傳 |
| `userId` | 知道是哪個使用者 |
| `index` | 該 tweet 在該使用者 tweet list 的位置 |

👉 **index 的存在是為了能往前補資料**

---

## getNewsFeed 拆解（逐步流程）

### Step 1️⃣：找出所有來源

```python
followeeIds =self.following.get(userId,set()) | {userId}
```

⚠️ 一定要把自己加進去

（使用者通常不會 follow 自己）

---

### Step 2️⃣：每個人只放「最新一則」進 heap

```python
idx =len(arr) -1
time, tweetId = arr[idx]
heapq.heappush(heap, (-time, tweetId, u, idx))
```

👉 heap size ≈ 追蹤人數 + 1

👉 不會爆記憶體

---

### Step 3️⃣：取出目前最新的 tweet

```python
negTime, tweetId, u, idx = heapq.heappop(heap)
ans.append(tweetId)
```

---

### Step 4️⃣：補同一個 user 的下一則舊 tweet

```python
if idx >0:
    time, tweetId =self.tweets[u][idx -1]
    heapq.heappush(heap, (-time, tweetId, u, idx -1))
```

👉 **k-way merge 的關鍵**

- 只補「剛剛被取走的那個來源」
- 其他來源維持不動

---

### Step 5️⃣：重複直到拿滿 10 則或 heap 為空

---

## follow / unfollow 的設計細節

```python
self.following.setdefault(followerId,set()).add(followeeId)
```

- `setdefault`：初始化 + 使用一次完成

```python
discard(followeeId)
```

- `discard` 不會丟 exception
- 比 `remove` 安全

---

## 時間與空間複雜度（面試必講）

### Time Complexity

- `postTweet`：O(1)
- `follow / unfollow`：O(1)
- `getNewsFeed`：
```plain text
O((F+ K)logF)
```
    - F = followees 數量
    - K = 10（常數）

👉 實際上非常快

---

### Space Complexity

- `tweets`：O(總 tweet 數)
- `heap`：O(F)

---

## 為什麼這題不用 global heap？

❌ 把所有 tweet 丟進一個 heap：

- 插入成本高
- 每次 getNewsFeed 都要掃很多不相關資料

✅ 正確做法：

- heap 是「臨時用來 merge 的工具」
- 不存全域狀態

---

## 面試加分補充（可選）

- 可以限制每個 user 只保留最近 10 則 tweet
- 可再壓低記憶體
- 但非必要，正確性優先

---

## 一句話總結（面試可背）

> 這題是典型的 k-way merge 問題，
> 每個使用者的 tweet 本身已排序，
> 
> 用 heap 合併多個來源，只維護最新候選，
> 
> 能有效取得最新 10 則貼文而不掃描全部資料。

---

## 常見錯誤（你可以放在 Notion 的 ⚠️ 區塊）

- 忘記把自己加進 followeeIds
- heap 裡沒存 index，導致無法補資料
- 把所有 tweet 都放 heap（效能爆炸）
- unfollow 用 remove 直接噴 error