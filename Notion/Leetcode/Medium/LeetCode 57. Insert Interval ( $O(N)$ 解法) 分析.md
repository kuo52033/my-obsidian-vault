---
notion-id: 2a85a6e2-1812-80a0-b0ab-d2333fff9910
---
### 1. 難度 (最高五星)

- **難度：** ★★☆☆☆ (2/5)
- **說明：** 這是一道 "Medium" 難度的題目。但它有一個**關鍵線索**：`intervals` 陣列**已經是排序好的**。這使得這題比 56. Merge Intervals (需要 $O(N \log N)$ 排序) 更快，只需要 $O(N)$ 的一次遍歷。

### 2. 核心技巧：一次遍歷 (Single Pass) + 分三階段處理

你的程式碼完美地將 $O(N)$ 的遍歷分成了三個清晰的階段：

1. **階段 1：無重疊 (在 **`**newInterval**`** 之前)**
2. **階段 2：有重疊 (與 **`**newInterval**`** 合併)**
3. **階段 3：無重疊 (在 **`**newInterval**`** 之後)**

---

### 核心邏輯分析 (你的程式碼)

你的程式碼使用一個 `curr` 指針，非常漂亮地完成了這三階段的任務：

### 階段 1：處理「之前」的區間

Python

`# 1. 遍歷所有 "結束時間" < "newInterval 開始時間" 的區間
while curr < end and intervals[curr][1] < newInterval[0]:
    result.append(intervals[curr])
    curr += 1`

- **分析：** 這些區間 `intervals[curr]` **完全**在 `newInterval` 的左邊，沒有任何重疊。
- **動作：** 它們是安全的，直接 `append` 到 `result` 中。

### 階段 2：處理「重疊」的區間 (最精華的部分)

Python

`# 2. 遍歷所有 "開始時間" <= "newInterval 結束時間" 的區間
while curr < end and intervals[curr][0] <= newInterval[1]:
    # 透過 "修改 newInterval" 來 "合併" 區間
    newInterval[0] = min(intervals[curr][0], newInterval[0])
    newInterval[1] = max(intervals[curr][1], newInterval[1])
    curr += 1`

- **分析：** 這是你提到的「**修改 **`**newInterval**`」。
- `while` 迴圈會捕捉所有**任何**與 `newInterval` 有重疊的 `intervals[curr]`。
- **動作：** 你不把 `intervals[curr]` 加到 `result`，而是用它來「**擴大**」`newInterval` 的範圍。
    - `newInterval` 的「開始時間」`[0]` 被更新為*兩者中*的**最小值**。
    - `newInterval` 的「結束時間」`[1]` 被更新為*兩者中*的**最大值**。
- `while` 迴圈結束後，`newInterval` 已經變成了「所有重疊區間合併後的最終型態」。

### 階段 3：處理「之後」的區間

Python

`# 3. 將 "最終合併" 的 newInterval 加入
result.append(newInterval)

# 4. 把剩下所有 "晚於" newInterval 的區間加入
while curr < end:
    result.append(intervals[curr])
    curr += 1`

- **分析：** 執行到這裡的 `intervals[curr]` 都是「階段 2」 `while` 迴圈沒處理的。這代表它們的「開始時間」`[0]` **大於** `newInterval` (合併後) 的「結束時間」`[1]`。
- **動作：** 先 `append` 合併完成的 `newInterval`，然後再 `append` 所有剩下的、無重疊的 `intervals`。

---

### 4. 時間與空間複雜度

- $N$ = `intervals` 列表的長度。
4. **時間複雜度 (Time Complexity): $O(N)$**
    - **分析：** 你的三個 `while` 迴圈，`curr` 指針**總共**只會從 `0` 走到 `end` (即 $N$) **一次**。
    - 這是一個**單次遍歷 (Single Pass)** 演算法，所以時間複雜度是 $O(N)$。
5. **空間複雜度 (Space Complexity): $O(N)$**
    - **分析：** `result` 列表在最壞情況下 (沒有任何合併) 會儲存 $N+1$ 個元素。因此空間複雜度是 $O(N)$。
    - (P.S. 由於 `result` 是「輸出」，如果只看「輔助空間」，你的演算法是 $O(1)$)