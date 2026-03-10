---
tags:
  - greedy
---

## 題目理解

給一個陣列，每個位置的值代表最多能跳幾步，保證一定能到終點，求**最少跳幾次**。

---

## 關鍵觀察

不需要追蹤每一種跳法，只需要知道：

- `farthest`：目前能到達的最遠位置
- `curr`：當前這一跳能到達的邊界

**當走到邊界 `curr` 時，代表這一跳用完了，必須再跳一次。**

---

## 解題框架

用 **[[Greedy]]**

```
每走一步更新 farthest
走到 curr 邊界時：
  → 必須跳了，count++
  → 下一跳的邊界 = farthest
```

---

## 實作

python

```python
def jump(self, nums):
    farthest = 0
    count = 0
    curr = 0  # 當前這跳的邊界

    for i in range(len(nums) - 1):  # 不需要走到最後一格
        farthest = max(farthest, i + nums[i])

        if i == curr:       # 走到當前跳的邊界
            count += 1      # 必須再跳一次
            curr = farthest # 下一跳的邊界更新

    return count
```

---

## 複雜度

| | |
|---|---|
| Time | O(n) |
| Space | O(1) |

---

## 我卡在哪 / 要注意的地方

**`curr` 和 `farthest` 的差別：**
```
nums = [2, 3, 1, 1, 4]

i=0: farthest = max(0, 0+2) = 2
     i==curr(0) → count=1, curr=2

i=1: farthest = max(2, 1+3) = 4
i=2: farthest = max(4, 2+1) = 4
     i==curr(2) → count=2, curr=4

i=3: farthest = max(4, 3+1) = 4
     （不到邊界，繼續走）

loop 結束（不走 index 4）→ return 2
```

**視覺化：**
```
[2,  3,  1,  1,  4]
 ↑
 第一跳範圍：0~2
     ↑   ↑
     走完第一跳範圍，count=1，下一跳範圍：0~4
                 終點在範圍內，不需要再跳
````

**為什麼 `range(len(nums)-1)` 不走最後一格：**

題目保證一定能到終點，走到倒數第二格就夠了，走到終點不需要再跳。

**`curr` 是「這一跳的通行證」**：只要還在 `curr` 範圍內就不用跳，走到 `curr` 才必須跳。

---

## 對比 LC-55

|      | LC-55 Jump Game        | LC-45 Jump Game II               |
| ---- | ---------------------- | -------------------------------- |
| 問題   | 能不能到終點                 | 最少幾跳                             |
| 變數   | 只需要 `farthest`         | 需要 `farthest` + `curr` + `count` |
| 關鍵判斷 | `i > farthest` → False | `i == curr` → 必須跳                |

---

## Flashcards

`curr` 在 Jump Game II 代表什麼 :: 當前這一跳能到達的邊界，走到這裡就必須再跳一次

為什麼 loop 只走到 `len(nums)-1` :: 到達終點不需要再跳，走到倒數第二格就能決定答案

`farthest` 和 `curr` 的差別 :: `farthest` 是目前看到的最遠可達位置；`curr` 是當前這跳的邊界，到了才更新 count

---

## 相關題目

- [[LC-55-Jump-Game]] ← 同場景，只問能不能到，不問幾跳