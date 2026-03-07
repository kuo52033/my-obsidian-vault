---
tags:
  - interval
  - sorting
---


## 題目理解

給一堆**未排序**的 intervals，把所有重疊的合併，回傳不重疊的結果。

---

## 關鍵觀察

- 先 sort by 起點，重疊的 interval 就會相鄰
- 不需要看整個 result，**只需要看 `result[-1]`** 就能決定要不要合併
    - 因為已排序，新進來的 interval 起點一定 ≥ 前面所有的起點
    - 唯一可能重疊的只有最後一個

---

## 解題框架

用 **[[Interval Pattern]]**

```
sort by 起點
→ 逐一掃描
  → result 是空的            → 直接加入
  → result[-1][1] >= 當前起點 → 合併（更新 result[-1][1]）
  → 否則                     → 直接加入
```

---

## 實作

```python
def merge(self, intervals):
    intervals.sort(key=lambda v: v[0])
    result = []

    for interval in intervals:
        if not result:
            result.append(interval)
        else:
            if result[-1][1] >= interval[0]:
                result[-1][1] = max(result[-1][1], interval[1])
            else:
                result.append(interval)

    return result
```


## 我卡在哪 / 要注意的地方

- **`result[-1]` 是關鍵**：sort 之後只需要跟最後一個比，不用回頭看整個 result
- 合併時用 `max(result[-1][1], interval[1])` 而不是直接賦值，因為可能遇到被完全包住的情況：

  [1, 10] 和 [2, 3] → 結果應該是 [1, 10]，不是 [1, 3]

---

## Flashcards

為什麼 sort 後只需要看 `result[-1]` :: 已排序保證新 interval 起點 ≥ 所有前面的起點，唯一可能重疊的就是最後一個

合併時為什麼用 `max(result[-1][1], interval[1])` :: 避免被完全包住的情況被縮短，例如 [1,10] 和 [2,3] 結果應為 [1,10]

Merge Intervals 框架 :: sort by 起點 → 逐一掃描 → 看 result[-1] 決定合併或新增

---

## 相關題目

- [[LC-57 Insert Interval]] ← 已排序版本，三段式掃描