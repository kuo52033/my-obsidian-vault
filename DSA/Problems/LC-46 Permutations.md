---
tags:
  - backtracking
  - recursion
---

## 題目理解

給一個不重複的整數陣列，回傳所有可能的排列。

---

## 解法一：Swap Backtracking

### 核心思路

每個位置輪流放不同的數字，swap 來模擬「這個位置放哪個數字」，swap back 還原現場。

### 展開過程

```
[1,2,3]
swap(0,0)→[1,2,3] → swap(1,1)→[1,2,3] → [1,2,3] ✓
                  → swap(1,2)→[1,3,2] → [1,3,2] ✓
swap(0,1)→[2,1,3] → ...
swap(0,2)→[3,2,1] → ...
```

### 實作

python

```python
def permute(self, nums):
    result = []

    def exchange(curr_idx, curr_n):
        if curr_idx == len(nums) - 1:
            result.append(list(curr_n))
            return

        for i in range(curr_idx, len(nums)):
            curr_n[i], curr_n[curr_idx] = curr_n[curr_idx], curr_n[i]
            exchange(curr_idx + 1, curr_n)
            curr_n[i], curr_n[curr_idx] = curr_n[curr_idx], curr_n[i]

    exchange(0, nums)
    return result
```

---

## 解法二：遞迴插入法

### 核心思路

把第一個數字插入到子問題的每個排列的每個位置。

### 展開過程
```
permute([3])   = [[3]]

permute([2,3])：
  把 2 插入 [3]：
  → [2,3], [3,2]

permute([1,2,3])：
  把 1 插入 [2,3]：[1,2,3], [2,1,3], [2,3,1]
  把 1 插入 [3,2]：[1,3,2], [3,1,2], [3,2,1]
````

### 實作

python

```python
def permute(self, nums):
    if len(nums) == 0:
        return [[]]

    perm = self.permute(nums[1:])
    res = []

    for p in perm:
        for i in range(len(p) + 1):
            p_copy = p.copy()
            p_copy.insert(i, nums[0])
            res.append(p_copy)

    return res
```

### 注意

`return [[]]` 不是 `return []`：
- `[[]]` = 有一個空排列，外層迴圈可以跑
- `[]` = 沒有任何排列，迴圈不會執行

---

## 解法三：迭代插入法

### 核心思路

解法二的迭代版本，用 `perm` 維護「目前為止的所有排列」，每次把新數字插入所有現有排列的每個位置。

### 展開過程
```
初始：perm = [[]]

num=1：把 1 插入 [[]] 每個位置
  → [[1]]

num=2：把 2 插入 [[1]] 每個位置
  → [[2,1], [1,2]]

num=3：把 3 插入 [[2,1], [1,2]] 每個位置
  → [[3,2,1], [2,3,1], [2,1,3],
     [3,1,2], [1,3,2], [1,2,3]]
````

### 實作

python

```python
def permute(self, nums):
    perm = [[]]

    for num in nums:
        temp_perm = []
        for p in perm:
            for i in range(len(p) + 1):
                p_copy = p.copy()
                p_copy.insert(i, num)
                temp_perm.append(p_copy)
        perm = temp_perm

    return perm
```

---

## 三種解法對比

| | 解法一（Swap） | 解法二（遞迴插入） | 解法三（迭代插入） |
|---|---|---|---|
| 方向 | 由上而下 | 由下而上 | 由左而右 |
| In-place | ✓ | ✗ | ✗ |
| 需要 call stack | ✓ | ✓ | ✗ |
| Space | O(n) | O(n²) | O(n²) |
| 直覺難度 | 難（swap 邏輯） | 中（遞迴拆解） | 易（逐步擴展） |

**Time 都是 O(n × n!)**，共 n! 個排列，每個長度 n。

---

## 心智模型
```
解法一：「每個位置輪流坐不同的人，坐完換人，再坐回來」
解法二：「先排好後面的，再把第一個人插進每個空隙」
解法三：「每來一個新人，讓他試坐所有現有排列的每個位置」
````

---

## Flashcards

三種 Permutation 解法的核心差異 :: Swap 是 in-place 由上而下；遞迴插入是由下而上建新 list；迭代插入是逐步擴展不需要 call stack

迭代插入法為什麼初始是 `[[]]` :: 代表一個空排列，讓第一個 num 可以插入，最終變成 `[[num]]`

解法一 swap back 的意義 :: 還原現場讓下一輪試別的數字，這是 backtracking 的核心