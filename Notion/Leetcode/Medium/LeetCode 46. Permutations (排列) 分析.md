---
notion-id: 29c5a6e2-1812-80a4-a801-d64817024b06
---
### 1. 難度 (最高五星)

- **難度：** ★★★☆☆ (3/5)
- **說明：** 這是一道 "Medium" 難度的題目，也是「回溯法 (Backtracking)」最經典的入門題之一。它考察的是你如何窮舉一個集合的所有「排列」可能。

### 2. 運用到的技巧

1. **回溯演算法 (Backtracking / DFS):**
    - 你的 `combine` 函式是一個標準的 DFS 探索。
2. **原地交換 (In-place Swap):**
    - 這是你解法的核心技巧，也是「選擇 (Choose)」和「撤銷 (Un-choose)」的具體實現。
    - 相比「`visited` 陣列」法，這種方法在輔助空間上更優 (不需要 $O(N)$ 的 `visited` 陣列)。

### 3. 核心邏輯分析 (你寫法的精妙之處)

這個解法非常聰明，我們來拆解 `combine(nums, index)` 的意義：

- `**index**`** 的意義：**
    - `index` 代表「**我現在要決定 *****第 ***`***index***`*** 個***** 位置要放哪個數字**」。
    - `nums[0 ... index-1]` ( `index` 左邊的)：是「**已經固定**」的數字。
    - `nums[index ... n-1]` ( `index` 和它右邊的)：是「**可以拿來用**」的數字。
- `**for i in range(index, len(nums))**`**:**
    - **意義：** 遍歷所有「**可以拿來用**」的數字 (從 `index` 自己到結尾)。
    - `i` 代表你想「**選中**」的那個數字的索引。
- `**nums[index], nums[i] = nums[i], nums[index]**`** (選擇 Choose)**
    - **意義：** 你「**選擇**」了 `nums[i]` 這個數字，並透過「交換」，把它「**固定**」到 `index` 這個位置上。
- `**self.combine(nums, index+1)**`** (探索 Explore)**
    - **意義：** `index` 位置已經填好了，現在我往下遞迴，去填「**下一個位置**」(`index + 1`)。
- `**nums[index], nums[i] = nums[i], nums[index]**`** (撤銷 Un-choose)**
    - **意義：** 這是**回溯的精髓**！
    - 當 `combine(..., index+1)` 這條路徑探索完畢並返回時，你**必須**把剛剛的交換「**換回來**」。
    - **為什麼？** 為了「重置 (reset)」`nums` 陣列，讓 `for` 迴圈在下一次 ( `i+1` ) 時，是從「**乾淨的、未交換過**」的狀態開始，去選擇 `nums[i+1]`。

### 4. 時間與空間複雜度

- $N$ = `nums` 的長度。
3. **時間複雜度 (Time Complexity): $O(N \times N!)$**
    - **$N!$** (N 階乘)： 總共會有 $N!$ 個排列組合 ( $N!$ 個葉節點)。
    - **$N$**： 在每個葉節點 (基礎情況)，`self.result.append(list(nums))` 需要 $O(N)$ 的時間來「**複製**」一個新的列表。
    - 總時間 = (產生所有解的成本) + (複製所有解的成本) $\approx O(N \times N!)$。
4. **空間複雜度 (Space Complexity): $O(N)$**
    - 我們*不*計算 `self.result` (輸出) 的空間。
    - **遞迴堆疊 (Recursion Stack):** 你的遞迴 `combine` 最多會呼叫 $N$ 層 ( `index` 從 0 到 $N$)。
    - 由於你是「原地」交換，你**不需要**像 `visited` 陣列或 `current_path` 列表那樣的 $O(N)$ 輔助空間。
    - 因此，空間複雜度只由「遞迴深度」決定，即 **$O(N)$**。

---

### 程式碼逐行說明 (你的程式碼)

Python

```python
class Solution:
    def permute(self, nums: List[int]) -> List[List[int]]:
        self.result = []

        # 1. 開始回溯
        # nums: 我們要操作的 "原陣列"
        # index=0: 我們要開始填 "第 0 個" 位置
        self.combine(nums, 0)

        return self.result
        
    def combine(self, nums, index):
        
        # 2. 基礎情況 (Base Case)
        #    當 index 已經 "越過" 最後一個位置
        #    表示 nums[0...n-1] 都已 "固定"，一個排列已完成
        if index == len(nums):
            # 必須 append "複本" (copy)，
            # 否則 append 的是 nums 的 "參考"，它會繼續被交換
            self.result.append(list(nums))
            return 
        
        # 3. for 迴圈：
        #    遍歷所有 "可用的" 數字 (從 index 到 n-1)
        for i in range(index, len(nums)):
            
            # 4. 選擇 (Choose):
            #    把 "第 i 個" 數字和 "第 index 個" 位置交換
            #    意義：決定 "第 index 個" 位置要放 nums[i]
            nums[index], nums[i] = nums[i], nums[index]
            
            # 5. 探索 (Explore):
            #    index 位置已定，去處理 "下一個" (index + 1)
            self.combine(nums, index+1)
            
            # 6. 撤銷 (Un-choose / Backtrack):
            #    【重要】把剛剛的交換 "換回來"
            #    重置陣列，以便 for 迴圈的下一次 (i+1)
            #    能從 "乾淨" 的狀態開始
            nums[index], nums[i] = nums[i], nums[index]
```