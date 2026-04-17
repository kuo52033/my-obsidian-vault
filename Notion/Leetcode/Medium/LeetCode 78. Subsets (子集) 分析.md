---
notion-id: 2aa5a6e2-1812-80d2-ac71-d7783e0a241a
---
### 1. 難度 (最高五星)

- **難度：** ★★☆☆☆ (2/5)
- **說明：** 這是一道 "Medium" 難度的題目。它本身就是一個**演算法模板**。一旦你理解了這個模板，所有相關的組合題 (如 39, 40, 46, 47 題) 都會變得容易。

### 2. 運用到的技巧

1. **回溯演算法 (Backtracking / DFS):**
    - 你的 `combine` 函式就是一個「深度優先搜索 (DFS)」的遞迴。
    - 你的程式碼在「**決策樹 (Decision Tree)**」上進行探索，樹上的*每一個節點*都是一個合法的子集。

### 3. 核心邏輯分析 (你寫法的精妙之處)

你的 `combine` 函式有三個關鍵點：

**A. **`**self.result.append(list(arr))**`** (在迴圈 *****之前***** append)**

- **意義：** 這是這題和「Combination Sum」(39, 40 題) **最大的不同**！
- 在 Combination Sum 中，你只在 `sum == target` (即到達「葉節點」) 時才 append。
- 在這題，`[]` (空集合) 是一個解，`[1]` 是一個解，`[1, 2]` 也是一個解。
- **決策樹上的「每一個節點」都是一個解**。
- 因此，你的 `combine` 函式*一進來*，`arr` (當前路徑) 就*已經*是一個合法的子集了，所以你**立刻** `append(list(arr))`。

**B. **`**for i in range(index, len(self.nums)):**`** (迴圈)**

- **意義：** 這是「選擇 (Choose)」的過程。
- `index` 參數確保我們**只會往前看**。
    - 範例：`[1, 2, 3]`。當 `arr = [1]` 時，`index` 會是 1，`for` 迴圈從 `i=1` (數字 2) 開始。
    - 這保證了你只會產生 `[1, 2]`，而*不會*在 `arr = [2]` 時回頭去選 1，從而避免了 `[2, 1]` 這種重複的組合。

**C. 遞迴三步驟 (Choose / Explore / Un-choose)**

Python

`for i in range(index, len(self.nums)):
    # 1. 選擇 (Choose)
    arr.append(self.nums[i])
    
    # 2. 探索 (Explore)
    #    往下一個層級探索，
    #    並且 index 要傳入 "i + 1"，
    #    表示「下次請從我的下一個數字開始選」
    self.combine(arr, i + 1)
    
    # 3. 撤銷 (Un-choose / Backtrack)
    #    "i" 這條路走完了 (例如 [1, 2, 3])，
    #    把 "3" 拿出來 (arr 變回 [1, 2])，
    #    以便 for 迴圈下一次 (i+1) 繼續
    #    (雖然這個例子 i=2 已經是結尾了)
    arr.pop()`

### 4. 時間與空間複雜度

- $N$ = `nums` 陣列的長度。
2. **時間複雜度 (Time Complexity): $O(N \times 2^N)$**
    - **$2^N$ (解的數量)：** 對於 `nums` 中的 $N$ 個元素，每個元素都有「**選**」或「**不選**」兩種狀態，所以總共會有 $2^N$ 個子集。
    - **$N$ (複製的成本)：** 在 $2^N$ 個解 (子集) 中，你*每*找到一個，都要執行 `list(arr)` 來複製。一個子集的平均/最大長度與 $N$ 相關。
    - **總時間：** $O(N \times 2^N)$ (產生所有解並複製它們)。
3. **空間複雜度 (Space Complexity): $O(N)$**
    - 我們*不*計算 `self.result` (輸出) 的空間。
    - **遞迴堆疊 (Recursion Stack):** 你的遞迴 `combine` 最多會呼叫 $N$ 層 (例如 `[1, 2, 3, ... N]`)。
    - `arr` ( `current_path` ) 也會增長到 $O(N)$ 的大小。
    - 因此，輔助空間複雜度由「遞迴深度」決定，為 **$O(N)$**。

---

### 程式碼逐行說明 (你的程式碼)

Python

```python
class Solution:
    def subsets(self, nums: List[int]) -> List[List[int]]:
        self.result = []
        self.nums = nums

        # 1. 開始回溯
        # arr = [] (當前路徑為空)
        # index = 0 (從 nums 的第 0 個元素開始 "考慮")
        self.combine([], 0)

        return self.result

    # arr: "當前" 正在組合的子集 (e.g., [1, 2])
    # index: "下一次" 迴圈要從 nums 的哪個索引開始
    def combine(self, arr, index):

        # 2. [核心]：
        #    "決策樹" 上的 "每一個" 節點都是一個解。
        #    (包含一開始的 [])
        #    所以，"一進來" 就先把 "arr" 的 "複本" 加入結果
        self.result.append(list(arr))
        
        # (這裡沒有 "if len(arr) == ..." 的 Base Case，
        #  因為 for 迴圈的 index 限制 "自動" 處理了)

        # 3. 遍歷 "可選擇" 的數字
        #    從 "index" 開始，確保我們只往前看
        for i in range(index, len(self.nums)):
            
            # 4. 選擇 (Choose):
            #    把 nums[i] 加入當前路徑
            arr.append(self.nums[i])
            
            # 5. 探索 (Explore):
            #    遞迴下去，並告訴下一層：
            #    "請從 i + 1 的位置開始選"
            self.combine(arr, i + 1)
            
            # 6. 撤銷 (Un-choose / Backtrack):
            #    "combine(arr, i + 1)" 這條路 (e.g., [1, 2]) 走完了，
            #    把 "2" 彈出 (arr 變回 [1])，
            #    這樣 for 迴圈的下一次 (i=2) 才能選 "3"，
            #    去探索 [1, 3] 這條路。
            arr.pop()
```