---
notion-id: 29a5a6e2-1812-80b0-9a2e-c6ad11acb22b
---
### 1. 難度 (最高五星)

- **難度：** ★★★☆☆ (3/5)
- **說明：** 這是一道 "Medium" 難度的題目。它是第 39 題 (Combination Sum) 的進階版，難度更高，因為它同時加入了兩個限制：
    1. `candidates` 中有重複數字。
    2. 每個數字在一個組合中**只能使用一次**。
- 你必須同時完美處理這兩個限制。 

### 2. 運用到的技巧

1. **回溯演算法 (Backtracking / DFS):**
    - 你的 `backTracking` 函式是一個標準的 DFS 探索。
    - 它同樣遵循「選擇 (Choose) $\to$ 探索 (Explore) $\to$ 撤銷 (Un-choose)」的模式。
2. **排序 (Sorting):**
    - `candidates.sort()`
    - **這是本題的「絕對前提」**。沒有排序，你就無法將重複的數字排在一起，`if j > index ...` 這個去重複的技巧就會完全失效。
3. **剪枝 (Pruning) - 共兩種：**
    - **剪枝 1 (去重複)：**
        - `if j > index and val == self.candidates[j - 1]: continue`
        - 這是你問的核心。它的意思是：「在**同一層**的 `for` 迴圈選擇中，如果我發現這個數字 `val` 和它*前一個*數字 `[j-1]` 一樣，我就跳過。」
        - `j > index` 是為了確保我們*不會*跳過 `for` 迴圈的第一個元素 ( `j == index` )，我們只跳過*同一層*中的*後續*重複元素。
        - **效果：** `[1, 2a, 2b]`，我們只會用 `2a` 開頭 ( `[1, 2a, ...]` )，而 `[1, 2b, ...]` 這整條路徑都會被 `continue` 剪掉。
    - **剪枝 2 (效能)：**
        - `if current_sum + val > self.target: break`
        - 因為陣列已排序，如果連當前的 `val` 加上去都超過 `target`，那麼後面的數字（更大）也一定會超過。`break` 可以讓我們提前結束這一層 `for` 迴圈。

### 3. 核心邏輯分析 (與 39 題的關鍵不同)

4. **每個數字只能用一次：**
    - **第 39 題 (可重複)：** `self.backTracking(..., j, ...)`
    - **第 40 題 (你寫的)：** `self.backTracking(..., j + 1, ...)`
    - **分析：** 你傳入了 `j + 1`，這代表下一層遞迴的 `for` 迴圈 `range(j+1, ...)` 將**從下一個索引**開始。這就保證了 `candidates[j]` 這個數字不會在下一層被再次選中。
5. **結果不能有重複組合：**
    - 這就是靠「**排序 + 剪枝 1**」來解決的。
    - 我們在 `[1a, 2a, 2b, 2c, 5a]` (target=5) 的例子中看到：
        - `[1a, 2a, 2b]` $\to$ 成功找到 `[1, 2, 2]`
        - `[1a, 2a, 2c]` $\to$ `continue` 剪掉 ( `j > index` 且 `2c == 2b` )
        - `[1a, 2b, ...]` $\to$ `continue` 剪掉 ( `j > index` 且 `2b == 2a` )
        - `[2a, 2b, ...]` $\to$ (會找到 `[2, 2, 1]`，但順序不同而已，邏輯是對的)
        - `[2b, ...]` $\to$ `continue` 剪掉 ( `j > index` 且 `2b == 2a` )
        - `[2c, ...]` $\to$ `continue` 剪掉 ( `j > index` 且 `2c == 2b` )

### 4. 時間與空間複雜度

- $N$ = `candidates` 陣列的長度。
- $T$ = `target` 的值。
6. **時間複雜度 (Time Complexity): $O(N \times 2^N)$**
    - **排序：** `candidates.sort()` 花費 $O(N \log N)$。
    - **回溯：** 這是「子集 (Subsets)」問題的變形。在最壞情況下，我們需要探索 $2^N$ 種組合 (每個元素選或不選)。
    - **複製：** 在每個找到的解 (葉節點)，我們都需要花 $O(k)$ ( $k$ 是組合的平均長度，最長為 $N$) 的時間來執行 `list(current_path)` 複製。
    - 總時間 = $O(N \log N + N \times 2^N)$。通常由回溯部分 $O(N \times 2^N)$ 主導。
7. **空間複雜度 (Space Complexity): $O(N)$**
    - **排序：** Python 的 Timsort 可能需要 $O(N)$ 的額外空間。
    - **遞迴堆疊 (Recursion Stack):** 遞迴的最深層級就是 `candidates` 的長度 $N$ (例如 `[1, 1, 1, 1]` target=4，深度為 4)。
    - `current_path` 列表也會增長到 $O(N)$ 的大小。
    - 因此，輔助空間複雜度由遞迴深度決定，為 $O(N)$。 (我們不計算 `self.result` 的輸出空間)

---

### 程式碼逐行說明 (你的程式碼)

Python

```python
class Solution:
    def combinationSum2(self, candidates: List[int], target: int) -> List[List[int]]:
        self.result = []
        # 1. 排序：這是 "去重複" 剪枝的絕對前提
        candidates.sort()
        self.candidates = candidates
        self.target = target

        # 2. 開始回溯
        # (current_path, start_index, current_sum)
        self.backTracking([], 0, 0)

        return self.result
    
    def backTracking(self, current_path, index, current_sum):
        
        # 3. 基礎情況 (成功)
        if current_sum == self.target:
            # 必須 append "複本"
            self.result.append(list(current_path))
            # 這裡少了一個 return，雖然功能上沒錯 (因為 j 迴圈會 break)
            # 但加上 return 更清晰
            # return 

        # 4. for 迴圈：代表 "同一層" 的所有選擇
        for j in range(index, len(self.candidates)):
            
            val = self.candidates[j]

            # 5. 【剪枝 1：去重複】
            #    - "j > index" : 表示我們不在這層迴圈的第一個元素
            #    - "val == self.candidates[j - 1]" : 表示當前數字和前一個一樣
            #    - 效果：[1, 2a, 2b] 中，只用 2a，跳過 2b
            if j > index and val == self.candidates[j - 1]:
                continue

            # 6. 【剪枝 2：效能】
            #    - 因為已排序，如果 "當前和 + val" 已超過 target
            #    - 後面更大的數字也必定超過，故可 break
            if current_sum + val > self.target:
                break
            
            # 7. 選擇 (Choose)
            current_path.append(val)
            
            # 8. 探索 (Explore)
            #    - 傳入 "j + 1"：因為每個數字只能用一次
            self.backTracking(current_path, j + 1, current_sum + val)
            
            # 9. 撤銷 (Un-choose / Backtrack)
            current_path.pop()
```