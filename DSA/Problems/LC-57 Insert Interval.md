---
tags:
  - array
  - interval
---

## 題目理解

給一個**已排序且不重疊**的 interval 列表，插入一個新的 interval，合併所有重疊的部分，回傳結果。

---

## 關鍵觀察

所有 interval 分成三個區段處理：

```
[完全在左邊] ... [有重疊] ... [完全在右邊]
```

- **完全在左邊**：`intervals[i][1] < newInterval[0]` → 直接加入
- **有重疊**：`intervals[i][0] <= newInterval[1]` → 合併到 newInterval
- **完全在右邊**：剩下的 → 直接加入

---

## 解題框架

用 **[[Interval Pattern]]**

三段式掃描，用 index 推進，不需要回頭：

```
1. 跳過所有在左邊的 → append
2. 合併所有重疊的   → 更新 newInterval 的邊界
3. 加入 newInterval
4. 剩下的直接 append
```

---

## 實作

python

```python
def insert(self, intervals, newInterval):
    result = []
    index = 0
    totalLen = len(intervals)
    
    # 完全在左邊，不重疊
    while index < totalLen and intervals[index][1] < newInterval[0]:
        result.append(intervals[index])
        index += 1

    # 有重疊，持續合併
    while index < totalLen and intervals[index][0] <= newInterval[1]:
        newInterval[0] = min(newInterval[0], intervals[index][0])
        newInterval[1] = max(newInterval[1], intervals[index][1])
        index += 1

    result.append(newInterval)

    # 完全在右邊
    while index < totalLen:
        result.append(intervals[index])
        index += 1
    
    return result
```

---

## [[time and space complexity]]

- Time O(n), 每個 interval 只跑一次
- Space O(n), result 儲存輸出
---

## 我卡在哪 / 要注意的地方
- 左邊結束的沒重疊判斷是? :: `intervals[i][1] < newInterval[0]
- 如何讓 newInterval 加入 result? ::  `newInterval` 直接 mutate 沒問題
-  newInterval 的重疊判斷是? ::`intervals[i][0] <= newInterval[1]`