---
notion-id: 2ab5a6e2-1812-80d5-a53d-f58b05bf6faf
---
## 程式碼目標 🎯

給定一個可能包含重複數字的陣列 `nums`，目標是返回它所有的「唯一」子集。

例如，如果 `nums = [1, 2, 2]`，那麼：

- `[1, 2]`（使用第一個 2）
- `[1, 2]`（使用第二個 2）

這兩個在「結果」中應被視為**同一個**子集。你的程式碼就是為了處理這種情況。

## 核心概念：排序 + 迴溯 + 剪枝

你的程式碼能成功，依賴了三個關鍵點：

1. **排序 (Sorting)**：這是**最關鍵**的第一步。透過排序，所有重複的元素都會被排在一起 (例如 `[1, 2, 2, 3]`)。這使得我們在後續步驟中可以輕易地「跳過」重複選項。
2. **迴溯 (Backtracking)**：`combine` 函式就是一個迴溯函式。它透過 `arr.append()`（選擇）、`self.combine(arr, i + 1)`（探索）和 `arr.pop()`（撤銷選擇）來窮舉所有可能的組合。
3. **剪枝 (Pruning)**：`if i != index and self.nums[i] == self.nums[i - 1]:` 這一行就是「剪枝」邏輯。它會「剪掉」那些會產生重複子集的遞迴分支。

---

## 程式碼詳解 breakdown

讓我們一步步拆解你的程式碼：

### 1. `subsetsWithDup` 函式 (主函式)

這是啟動器，負責前置作業。

Python

`    def subsetsWithDup(self, nums: List[int]) -> List[List[int]]:
        # 1. 初始化結果列表
        self.result = []
        
        # 2. 排序 (關鍵！)
        #    必須排序，才能讓後續的 "去重" 邏輯生效
        self.nums = sorted(nums)

        # 3. 開始遞迴
        #    傳入一個空陣列 (當前的子集) 和起始索引 0
        self.combine([], 0)

        # 4. 返回所有收集到的子集
        return self.result`

### 2. `combine` 函式 (遞迴的 Backtracking 核心)

這個函式是演算法的主體。

Python

`    def combine(self, arr, index):

        # 1. 收集結果
        #    在迴溯中，"路徑上的每一個節點" 都是一個合法的子集。
        #    (例如 []、[1]、[1, 2] 都是子集)
        #    所以我們在遞迴的「一開始」就立刻收集當前的 'arr'
        #    必須用 list(arr) 來 "複製" 一份，否則會存到 reference
        self.result.append(list(arr))

        # 2. 迴圈探索
        #    從 'index' 開始，遍歷所有「可用」的數字
        for i in range(index, len(self.nums)):
            
            # 3. 去重剪枝 (Pruning) (本題最精華的部分！)
            #    這行的意思是：
            #    "如果 i 不是當前迴圈的第一個元素 (i != index)，
            #     並且 當前元素和它「前一個」元素相同 (self.nums[i] == self.nums[i - 1])"
            #    ... 那麼就跳過 (continue)
            #
            #    [圖解] 假設 nums = [1, 2, 2'] (2' 代表第二個 2)
            #    - 我們從 index=1 開始 (第一個 2)
            #    - i = 1 (值 2): 
            #      i == index (1 == 1)，條件不成立。我們 "選擇" 2。
            #      遞迴 [1, 2]
            #    - i = 2 (值 2'):
            #      i != index (2 != 1) **而且** nums[2] == nums[1] (2' == 2)，條件成立。
            #      我們 "跳過" 2'。
            #
            #    這就避免了在同一層遞迴中，選擇 2 和 2' 產生兩次 [1, 2] 的重複情況。
            if i != index and self.nums[i] == self.nums[i - 1]:
                continue
                
            # 4. 選擇 (Choose)
            #    將當前數字加入到 "路徑" (arr) 中
            arr.append(self.nums[i])
            
            # 5. 探索 (Explore)
            #    繼續往下一層遞迴。
            #    注意：下一次的起始索引是 'i + 1'，不是 'index + 1'。
            #    這確保了我們只會往後找，不會往前找 (例如 [1, 2] 而不是 [2, 1])
            self.combine(arr, i + 1)
            
            # 6. 撤銷選擇 (Unchoose / Backtrack)
            #    當 `combine(arr, i + 1)` 結束並返回時，
            #    我們把剛剛加入的數字 "彈出"，以準備嘗試 for 迴圈的下一個 i
            #    (例如：探索完 [1, 2] 後，彈出 2，準備嘗試 [1, 3] (如果有的話))
            arr.pop()`

---

## 總結

你提供的程式碼是解決「子集 II」問題的一個非常標準且高效的模板。

- `sorted(nums)` 是**去重的前提**。
- `if i != index and self.nums[i] == self.nums[i - 1]:` 是**去重的核心**。
- `arr.append()`, `combine(i + 1)`, `arr.pop()` 是**迴溯的框架**。

做得很好！這份程式碼的邏輯非常清晰。