---
notion-id: 2ab5a6e2-1812-802d-926d-f726b5653ecf
---
## 程式碼目標 🎯

這個程式碼的目標是在一個 2D 的字元網格 (`board`) 中，尋找是否存在一條路徑，其字元組合起來剛好等於目標字串 `word`。

- 路徑可以從**任何一個**格子開始。
- 每一步只能往**上、下、左、右**四個方向移動。
- 同一個格子在**同一條**路徑中不能重複使用。

## 核心概念：DFS + 迴溯法

你的程式碼完美地體現了這個概念：

1. **DFS (深度優先搜尋)**：
    - 從一個起始點開始，沿著一個方向（例如「下」）一直走到底，直到不能再走（碰到邊界、碰到已走過的格子、或字元不符合）。
    - 這體現在 `search` 函式遞迴呼叫自己的行為（例如 `self.search(row + 1, col, index + 1)`）。
2. **Backtracking (迴溯法)**：
    - 當一條路徑走到「死路」（例如下一個字元不符），程式需要「退回」到上一步，並嘗試下一個方向（例如改試「右」）。
    - 這在你的程式碼中由 `self.mark[row][col] = True`（標記）和 `self.mark[row][col] = False`（取消標記）這兩行關鍵程式碼實現。

---

## 程式碼詳解 breakdown

你的程式碼分為兩個主要部分：

3. `exist` (主函式)：負責**啟動**搜尋。
4. `search` (輔助函式)：負責**執行**遞迴搜尋。

### 1. `exist` 函式 (主函式)

這個函式是 LeetCode 呼叫的進入點。

Python

```python
    def exist(self, board: List[List[str]], word: str) -> bool:
        # 1. 初始化：將 board 和 word 存為實例變數，方便 search 函式取用
        self.board = board
        self.word = word
        
        # 2. 建立「標記」陣列 (mark / visited)
        #    用來記錄在「當前這條路徑」中，哪些格子已經被走過了
        #    初始值全為 False (都沒走過)
        self.mark = [[False] * len(board[0]) for _ in range(len(board))]

        # 3. 雙層迴圈：遍歷 grid 上的「每一個」格子
        for i in range(len(board)):
            for j in range(len(board[0])):
                # 4. 嘗試從 (i, j) 這個格子開始，尋找 word 的第 0 個字元
                hasWord = self.search(i, j, 0)

                # 5. 提早返回 (Early Return)
                #    只要任何一個起始點能成功找到 word，就立刻回傳 True
                if hasWord:
                    return True
        
        # 6. 如果所有格子都試過一輪，都找不到，才回傳 False
        return False
```

### 2. `search` 函式 (遞迴的 DFS 核心)

這個函式是演算法的核心。它會回答一個問題：「**從 **`**(row, col)**`** 出發，是否能找到 **`**word**`** 中 **`**index**`** 之後的字元？**」

Python

```python
    def search(self, row, col, index):
        # --- 遞迴的停止條件 (Base Cases) ---

        # 1. 成功找到：
        #    如果 index 已經等於 word 的長度，表示 word 所有的字元都已成功匹配
        if index == len(self.word):
            return True

        # 2. 失敗 (邊界檢查)：
        #    如果 (row, col) 超出了 grid 的範圍
        if row < 0 or row > len(self.board) - 1 or col < 0 or col > len(self.board[0]) - 1:
            return False

        # 3. 失敗 (已走過)：
        #    如果這個格子 (row, col) 在「當前路徑」中已經被標記 (mark) 過了
        if self.mark[row][col] == True:
            return False

        # 4. 失敗 (字元不匹配)：
        #    如果當前格子的字元，不等於我們要找的 word[index]
        if self.word[index] != self.board[row][col]:
            return False
        
        # --- 遞迴的探索 (DFS + Backtracking) ---
        
        # 5. 標記 (Mark)：
        #    表示 (row, col) 這個格子，我們「現在」要踩下去了
        self.mark[row][col] = True

        # 6. 探索 (Explore)：
        #    往 (row, col) 的「上、下、左、右」四個方向繼續遞迴搜索
        #    注意：index 要 +1，因為我們要找 word 的「下一個」字元
        found = (self.search(row + 1, col, index + 1) or  # 下
                 self.search(row - 1, col, index + 1) or  # 上
                 self.search(row, col + 1, index + 1) or  # 右
                 self.search(row, col - 1, index + 1))   # 左

        # 7. 迴溯 (Backtrack)：
        #    「非常重要！」
        #    不論上一步的 four-way 探索是否成功 (found 是 True 還是 False)，
        #    我們都要把 (row, col) 的標記取消 (設回 False)。
        #    為什麼？ 
        #    因為這樣「另一條」完全不同的路徑 (例如從別的起點開始的) 才有機會使用這個格子。
        self.mark[row][col] = False

        # 8. 回傳此路徑的結果
        return found
```

---

## 總結

你提供的這份程式碼結構非常標準且高效。`exist` 函式作為驅動器，`search` 函式利用遞迴和 `self.mark` 陣列實現了 DFS + 迴溯。

關鍵點在於 `search` 函式中的第 5 步（標記）和第 7 步（迴溯/取消標記）的配對，這確保了路徑的正確性。
