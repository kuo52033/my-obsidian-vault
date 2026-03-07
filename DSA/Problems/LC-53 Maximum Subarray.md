---
tags:
  - dp
  - greedy
  - kadane
---

## 題目理解

給一個整數陣列，找出總和最大的連續子陣列，回傳其總和。

---

## 關鍵觀察

每到一個新的數字，只有兩個選擇：

- **延續**前面的子陣列：`curr + num`
- **重新開始**：`num`（前面的包袱太重，不如從這裡重來）

取兩者的 max，就是 Kadane's Algorithm 的核心。

---

## 解題框架

用 **[[Kadane's Algorithm]]**

```
curr  = 到當前位置為止，包含當前元素的最大子陣列和
result = 全局最大值

每一步：
  curr = max(curr + num, num)
  result = max(result, curr)
```

---

## 實作

python

```python
def maxSubArray(self, nums):
    result = nums[0]
    curr = 0

    for num in nums:
        curr = max(curr + num, num)
        result = max(result, curr)

    return result
```

---

## 複雜度

|       |      |
| ----- | ---- |
| Time  | O(n) |
| Space | O(1) |

---

## 我卡在哪 / 要注意的地方

**`curr = max(curr + num, num)` 的意思：**

這行其實是在問：**「帶著前面的包袱，還是從這裡重新出發，哪個比較好？」**
```
nums = [-3, 1, -1, 2]

num=-3: curr = max(0-3, -3) = -3,  result = -3
num= 1: curr = max(-3+1, 1) = 1,   result = 1   ← 重新開始
num=-1: curr = max(1-1, -1) = 0,   result = 1   ← 延續
num= 2: curr = max(0+2,  2) = 2,   result = 2   ← 延續
````

**`max(curr + num, num)` 等價於：**

python

```python
if curr < 0:
    curr = num       # 前面是負的，丟掉重來
else:
    curr = curr + num  # 前面是正的，繼續累加
```

兩種寫法完全等價，但 `max` 寫法更簡潔。

---

## Flashcards

`curr = max(curr + num, num)` 的決策邏輯是什麼 :: 帶著前面的和繼續 vs 從當前重新開始，取較大值；等價於「curr < 0 就丟掉重來」

Kadane's Algorithm 兩個變數分別代表什麼 :: `curr` 是包含當前元素的局部最大和，`result` 是全局最大和

為什麼 `result` 初始化為 `nums[0]` 而不是 0 :: 全為負數時答案是最大的負數，初始化為 0 會錯誤回傳 0

---

## 相關題目

- [[LC-152-Maximum-Product-Subarray]] ← 同概念，改成乘積，需要同時追蹤最大和最小值
- [[LC-918-Maximum-Sum-Circular-Subarray]] ← Kadane 的進階變形