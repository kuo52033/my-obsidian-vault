---
notion-id: 2a75a6e2-1812-808c-ada6-e21186399b66
---
### 1. 難度 (最高五星)

- **難度：** ★★☆☆☆ (2/5)
- **說明：** 這是一道 "Medium" 難度的題目，但它是面試中**最經典**、**出現頻率最高**的題目之一。它考察的是你對「排序」和「貪心 (Greedy)」思想的應用。

---

### 2. 運用到的技巧

1. **排序 (Sorting):**
    - `intervals.sort(key=lambda v: v[0])`
    - 這是**最關鍵**的第一步。你根據每個區間的「**起始時間 (start time)**」`v[0]` 進行排序。
    - **為什麼必須排序？** 排序後，你才能保證當你遍歷 `interval` 時，任何「潛在的重疊」都**只會**發生在「當前 `interval`」和 `result` 列表中的「**最後一個** `result[-1]`」之間。
2. **貪心法 (Greedy Approach):**
    - 你的 `for` 迴圈就是一個貪心過程。在每一步，你只關心「當前 `interval`」和「`result` 中的最後一個區間」的關係，並做出「局部最優」的決策 (合併或新增)。

---

### 3. 核心邏輯分析 (你的程式碼)

你初始化 `result = []`，然後遍歷排序後的 `intervals`，你的 `if/elif/else` 邏輯非常完美：

- `**if not result:**`
    - **情況：** `result` 還是空的 (只在第一個 `interval` 時發生)。
    - **動作：** 直接把第一個 `interval` 加入 `result`。
- `**elif result[-1][1] < interval[0]:**`
    - **情況：** 這是「**沒有重疊 (No Overlap)**」的情況。
    - `result[-1][1]` (上一個合併區間的「結束時間」) **小於** `interval[0]` (當前區間的「開始時間」)。
    - **動作：** `result.append(interval)`。表示上一個區間已經「定案」了，將當前 `interval` 作為一個*新的*區間加入 `result`。
- `**else:**`
    - **情況：** 這是「**有重疊 (Overlap)**」的情況。
    - (因為 `result[-1][1] >= interval[0]` )
    - **動作：K**`**result[-1][1] = max(interval[1], result[-1][1])**`。
    - **分析：** 這是**合併的精髓**。你不 `append` 新區間，而是「**原地修改**」`result` 中的「最後一個」區間。
    - 你將 `result[-1]` 的「結束時間」`[1]`，更新為「它自己原來的結束時間」和「當前 `interval` 的結束時間」中**的較大值**。
    - **範例：** `result[-1] = [1, 5]`，`interval = [3, 8]`。`max(8, 5)` $\to$ `8`。`result[-1]` 被更新為 `[1, 8]`。
    - **範例：** `result[-1] = [1, 8]`，`interval = [3, 5]`。`max(5, 8)` $\to$ `8`。`result[-1]` 仍然是 `[1, 8]`。

---

### 4. 時間與空間複雜度

- $N$ = `intervals` 列表的長度。
3. **時間複雜度 (Time Complexity): $O(N \log N)$**
    - **分析：**
        - `intervals.sort(...)`：排序 $N$ 個元素，時間複雜度為 $O(N \log N)$。
        - `for interval in intervals:`：單次遍歷 $N$ 個元素，時間複雜度為 $O(N)$。
    - **總和：** $O(N \log N) + O(N)$。由「排序」主導，故總時間為 **$O(N \log N)$**。
4. **空間複雜度 (Space Complexity): $O(N)$**
    - **分析：**
        - **排序：** Python 的 Timsort 排序演算法，在最壞情況下需要 $O(N)$ 的額外空間。
        - `**result**`** 列表：** 在最壞情況下 (所有 `intervals` 都沒有重疊)，`result` 列表需要儲存 $N$ 個元素。
    - **總和：** **$O(N)$**。

---

### 程式碼逐行說明 (你的程式碼)

Python

```python
class Solution:
    def merge(self, intervals: List[List[int]]) -> List[List[int]]:
        
        # 1. 關鍵第一步：
        #    根據 "起始時間" (v[0]) 對所有區間進行排序
        #    O(N log N)
        intervals.sort(key=lambda v: v[0])
        
        # 2. 初始化結果列表
        result = []

        # 3. 遍歷排序後的 "每一個" 區間
        #    O(N)
        for interval in intervals:
            
            # 4. 情況 A：result 是空的
            #    (這只會發生在 "第一個" interval)
            if not result:
                result.append(interval)
            
            # 5. 情況 B：沒有重疊
            #    (上一個區間的 "結束" < 當前區間的 "開始")
            elif result[-1][1] < interval[0]:
                # 將 "當前區間" 作為一個 "新" 區間加入
                result.append(interval)
            
            # 6. 情況 C：有重疊
            #    (上一個區間的 "結束" >= 當前區間的 "開始")
            else:
                # "合併" 區間：
                # 不新增，而是 "更新" 上一個區間的 "結束時間"
                # 更新為 "兩者結束時間中的較大值"
                result[-1][1] = max(interval[1], result[-1][1])

        # 7. 返回合併後的列表
        return result
```