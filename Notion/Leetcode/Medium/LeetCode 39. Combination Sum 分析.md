---
notion-id: 29a5a6e2-1812-8071-a2d8-f63d35a5bceb
---
### 1. 難度 (最高五星)

- **難度：** ★★★☆☆ (3/5)
- **說明：** 這是一道 "Medium" 難度的經典回溯題。它考察的是你如何窮舉所有可能性，並正確處理「**數字可以重複使用**」的邏輯。

### 2. 運用到的技巧

1. **回溯演算法 (Backtracking / DFS):**
    - 你的 `combine` 函式是一個標準的 DFS 探索。
    - 它完美地展示了「**選擇 (Choose) -> 探索 (Explore) -> 撤銷 (Un-choose)**」的模式。
        - **選擇：** `li.append(num)`
        - **探索：** `self.combine(li, j, curr_sum + num)`
        - **撤銷：** `li.pop()`
2. **傳遞狀態 (State Passing):**
    - 你將 `curr_sum` 作為參數傳遞下去，避免了在每一步都重新呼叫 `sum(li)` (這會花 $O(k)$ 的時間， $k$ 是 `li` 的長度)，讓每次檢查都變成了 $O(1)$，這是非常棒的優化。
3. **排序與剪枝 (Sorting & Pruning):**
    - `**candidates.sort()**`**:** 你做了排序。
    - `**if curr_sum + num > self.target: break**`**:** 這是基於「排序」的**關鍵剪枝**。
    - **意義：** 因為陣列是有序的，如果連*當前*的 `num` 加上去都會超過 `target`，那麼*後面*更大的數字 `self.arr[j+1]`... 肯定也會超過。因此，我們可以安全地 `break` 這個 `for` 迴圈，不必再嘗試後面的數字，大大提高了效率。

### 3. 核心邏輯分析

- `**self.result.append(list(li))**`**:** 你正確地使用了 `list(li)` 來**建立一個複本**。這可以防止 `self.result` 裡面的答案隨著 `li` 的 `pop()` 而被清空。
- `**self.combine(li, j, ...)**`**:** (注意 `j` 這裡)
    - 你在「探索」時，下一次遞迴呼叫的*起始索引*仍然傳入 `j` (而不是 `j+1`)。
    - **這正是「數字可以重複使用」的關鍵！**
    - 傳入 `j` 允許下一層的 `for` 迴圈*再次*選擇 `self.arr[j]` 這個數字。

---

### 4. 時間與空間複雜度 (你提到的)

這部分是回溯法最 tricky 的地方，我們來分析一下：

- $N$ = `candidates` 陣列的長度。
- $T$ = `target` 的值。
- $M$ = `candidates` 中最小的數字 (這影響遞迴的深度)。
4. **時間複雜度 (Time Complexity): $O(N^{T/M})$**
    - **排序：** `candidates.sort()` 花費 $O(N \log N)$。
    - **回溯：** 這是主要成本。我們可以想像一個「決策樹」。
        - **樹的深度：** 在最壞情況下 (例如 `candidates = [1]`)，一個組合的路徑可以長達 $T$ (即 $T/M$)。
        - **分支因子：** 在樹的*每一層*，`for` 迴圈都可能讓我們從 $N$ 個數字中做選擇。
    - 因此，一個寬鬆的上限是 $O(N^{T/M})$ ( $N$ 的「最大深度」次方)。
    - 你做的 `break` 剪枝會大大優化這個速度，但 $O(N^{T/M})$ 是這類問題公認的漸近時間複雜度上限。
    - **總和：** $O(N \log N + N^{T/M})$，通常由回溯部分 $O(N^{T/M})$ 主導。
5. **空間複雜度 (Space Complexity): $O(T/M)$**
    - 這裡我們*不*計算儲存 `self.result` 的空間 (因為它是「輸出」)。
    - **排序：** Python 的 Timsort 可能需要 $O(N)$ 的額外空間。
    - **遞迴堆疊 (Recursion Stack):** 空間成本主要來自遞迴呼叫的深度。
    - 如上所述，遞迴的最深層級 (最長的組合) 是 $T/M$。
    - 同時，你的 `li` 列表 (儲存 `current_path`) 也會增長到 $O(T/M)$ 的大小。
    - 因此，輔助空間複雜度由遞迴深度決定，為 $O(T/M)$。

---

### 程式碼整理 (含更佳的變數名稱)

你的程式碼功能完美。如同我們上次討論的，我們可以把變數名稱改得更具可讀性 (更 Pythonic)，這在面試或協作時很有幫助：

Python

```python
class Solution:
    def combinationSum(self, candidates: List[int], target: int) -> List[List[int]]:
        
        self.result = []
        candidates.sort() # 排序是為了後續的 "剪枝" 優化
        # (變數名稱可以保持一致，self.candidates)
        # (self.target 也可以在遞迴時傳遞，但存為 self 成員也 OK)
        
        # 1. current_path (當前組合)
        # 2. start_index (for 迴圈的起始索引)
        # 3. current_sum (當前總和)
        self.backtrack(candidates, target, [], 0, 0)

        return self.result

    # 函式名稱改為 backtrack，參數名稱也更清楚
    def backtrack(self, candidates, target, current_path, start_index, current_sum): 
        
        # 基礎情況 (成功)：當前總和等於目標
        if current_sum == target:
            # 必須 append "複本 (copy)"
            self.result.append(list(current_path)) 
            return

        # (失敗的基礎情況 "current_sum > target" 被下面的剪枝取代了)

        # 遍歷 "candidates"，但從 "start_index" 開始
        for j in range(start_index, len(candidates)):
            
            num = candidates[j]
            
            # --- 剪枝 (Pruning) ---
            # 因為陣列已排序，如果 "當前和 + num" 已超過 target
            # 那 "當前和 + 後面更大的數字" 也必定超過，故可 break
            if current_sum + num > target:
                break
            
            # 1. 選擇 (Choose): 將數字加入當前路徑
            current_path.append(num)
            
            # 2. 探索 (Explore): 繼續遞迴
            #    - start_index 傳入 "j" (而非 j+1)，因為數字可以重複使用
            #    - 傳入新的總和
            self.backtrack(candidates, target, current_path, j, current_sum + num)
            
            # 3. 撤銷 (Un-choose / Backtrack):
            #    將數字移出路徑，以嘗試 for 迴圈的下一個 j
            current_path.pop()
```