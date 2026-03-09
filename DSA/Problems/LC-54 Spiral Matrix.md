---
tags:
  - matrix
  - simulation
---

## 題目理解

給一個 m × n 矩陣，按螺旋順序回傳所有元素。

---

## 關鍵觀察

用四個邊界 `top, bottom, left, right` 模擬螺旋，每走完一條邊就縮小對應邊界。

走的順序：

```
→ 右（top row）     → top++
↓ 下（right col）   → right--
← 左（bottom row）  → bottom--
↑ 上（left col）    → left++
```

---

## 解題框架

用 **[[Matrix Simulation]]**

```
while top <= bottom and left <= right:
    1. 走上邊  → top++
    2. 走右邊  → right--
    3. 提前檢查邊界（關鍵！）
    4. 走下邊  → bottom--
    5. 走左邊  → left++
```

---

## 實作

```python
def spiralOrder(self, matrix):
    top, bottom = 0, len(matrix) - 1
    left, right = 0, len(matrix[0]) - 1
    result = []

    while top <= bottom and left <= right:
        for u in range(left, right + 1):
            result.append(matrix[top][u])
        top += 1

        for r in range(top, bottom + 1):
            result.append(matrix[r][right])
        right -= 1

        # 提前檢查：避免單行或單列被重複走
        if top > bottom or left > right:
            break

        for b in range(right, left - 1, -1):
            result.append(matrix[bottom][b])
        bottom -= 1

        for l in range(bottom, top - 1, -1):
            result.append(matrix[l][left])
        left += 1

    return result
```

---

## 複雜度

|       |                  |
| ----- | ---------------- |
| Time  | O(m × n)，每個元素走一次 |
| Space | O(1)，不計輸出的話      |

---

## 我卡在哪 / 要注意的地方

**為什麼走完上邊和右邊之後要提前 break：**

走完 → 右、↓ 下之後，邊界已經縮了：
```
top++, right--
```

這時候可能剩下**單行或單列**，例如：
```
原本 3×3，走完上和右之後：
top=1, bottom=1, left=0, right=1

→ 如果不提前 break，繼續走「下邊」會從 right → left 反向再走一次同一行
→ 元素被重複加入
````

**心智模型**：走完右邊之後縮邊界，這時候要確認「還有沒有剩下的空間」，有才繼續走下邊和左邊。

---

**for 迴圈範圍整理：**

|方向|範圍|注意|
|---|---|---|
|→ 右|`range(left, right+1)`|先走，再 top++|
|↓ 下|`range(top, bottom+1)`|top 已縮，起點是新 top|
|← 左|`range(right, left-1, -1)`|right 已縮，起點是新 right|
|↑ 上|`range(bottom, top-1, -1)`|bottom 已縮，起點是新 bottom|

---

## Flashcards

Spiral Matrix 為什麼走完上和右之後要提前 break :: 邊界縮小後可能剩單行或單列，不 break 會重複走同一行/列

走「左邊」的 range 是什麼 :: `range(right, left-1, -1)`，注意 right 已經在走完右邊後縮小了

Spiral Matrix 四個方向走完後各縮哪個邊界 :: 右→top++ / 下→right-- / 左→bottom-- / 上→left++

---

## 相關題目
b