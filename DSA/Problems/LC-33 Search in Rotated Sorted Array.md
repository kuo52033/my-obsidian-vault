---
tags:
  - binary-search
---

## 題目理解

一個原本排序好的陣列被旋轉過（從某個點切開，左邊接到右邊），在裡面找 target，回傳 index，找不到回傳 -1。

```
原始：[1, 2, 3, 4, 5, 6, 7]
旋轉：[4, 5, 6, 7, 1, 2, 3]  ← 從 index 4 旋轉
```

---

## 關鍵觀察

旋轉後的陣列，**mid 把陣列切成兩半，其中一半一定是完全排序的**：

```
[4, 5, 6, 7, 1, 2, 3]
          ↑ mid=3 (值=7)

左半 [4,5,6,7] → 完全排序（nums[mid] >= nums[left]）
右半 [1,2,3]   → 完全排序
```

知道哪半是排序的，就能用邊界判斷 target 在不在裡面。

---

## 解題框架

用 **[[Binary Search Pattern]]**

```
while left <= right:
  算 mid
  找到 → return mid

  判斷哪半是排序的：
    左半排序（nums[mid] >= nums[left]）：
      target 在左半範圍內 → 往左找
      否則 → 往右找

    右半排序：
      target 在右半範圍內 → 往右找
      否則 → 往左找
```

---

## 實作

python

```python
def search(self, nums, target):
    left, right = 0, len(nums) - 1

    while left <= right:
        mid = (left + right) // 2

        if nums[mid] == target:
            return mid

        # 左半是排序的
        if nums[mid] >= nums[left]:
            if nums[left] <= target < nums[mid]:
                right = mid      # target 在左半
            else:
                left = mid + 1   # target 在右半
        # 右半是排序的
        else:
            if nums[mid] < target <= nums[right]:
                left = mid + 1   # target 在右半
            else:
                right = mid      # target 在左半

    return -1
```

---

## 複雜度

| | |
|---|---|
| Time | O(log n) |
| Space | O(1) |

---

## 我卡在哪 / 要注意的地方

**`nums[mid] >= nums[left]` 的意義：**

這行是在判斷「左半是不是排序好的」。
```
[4, 5, 6, 7, 1, 2, 3]
 ↑           ↑
left        mid

nums[mid]=7 >= nums[left]=4 → 左半 [4,5,6,7] 是排序的 ✓
```

反例（右半排序）：
```
[6, 7, 1, 2, 3, 4, 5]
 ↑        ↑
left      mid

nums[mid]=2 < nums[left]=6 → 左半 [6,7,1,2] 不是排序的
                            → 右半 [2,3,4,5] 是排序的
```

**為什麼用 `>=` 不是 `>`：**
```
[3, 1]
 ↑
left=0, mid=0

nums[mid]=3 == nums[left]=3
→ 用 > 會判斷錯，要用 >= 才能正確識別左半排序
````

**左半排序時的邊界判斷：**

python

```python
if nums[left] <= target < nums[mid]:
```

- 左閉：`nums[left] <= target`，target 可以等於左邊界
- 右開：`target < nums[mid]`，mid 已經確認不是 target，不用包含

**右半排序時的邊界判斷：**

```python
if nums[mid] < target <= nums[right]:
```

- 左開：`nums[mid] < target`，mid 已確認不是 target
- 右閉：`target <= nums[right]`，target 可以等於右邊界

---

## 視覺化
```
nums = [4, 5, 6, 7, 1, 2, 3], target = 1

left=0, right=6, mid=3, nums[mid]=7
  nums[7] >= nums[4] → 左半排序
  target(1) 不在 [4,7) → 往右找
  left = 4

left=4, right=6, mid=5, nums[mid]=2
  nums[2] < nums[4] → 右半排序
  target(1) 不在 (2,3] → 往左找
  right = 5

left=4, right=5, mid=4, nums[mid]=1
  nums[1] == target → return 4 ✓
```

---

## Flashcards

旋轉排序陣列中如何判斷左半是否排序 :: `nums[mid] >= nums[left]`，mid 值大於等於左邊界代表左半連續遞增

左半排序時 target 在左半的條件 :: `nums[left] <= target < nums[mid]`，左閉右開，mid 已確認不是 target

為什麼用 `>=` 不是 `>` 來判斷左半排序 :: 當 left == mid 時，`nums[mid] == nums[left]`，用 `>` 會判斷錯誤

---

## 相關題目

- [[LC-81-Search-in-Rotated-Sorted-Array-II]] ← 有重複數字的版本，邊界更複雜
- [[LC-153-Find-Minimum-in-Rotated-Sorted-Array]] ← 同樣旋轉陣列，找最小值