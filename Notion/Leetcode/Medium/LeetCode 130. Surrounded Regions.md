---
notion-id: 2b55a6e2-1812-804f-9555-d9f86e2d6452
---
## 📌 **面試常考程度：6/10**

雖不是最高頻，但是一題非常典型的 **DFS/BFS + grid traversal** 題。

許多公司愛考同類型（如 200、695、417）。

---

# 📌 **難度：6/10 (Medium)**

屬於模板題，但容易寫錯邊界，且思考方向要反過來（從邊界找不能被包住的 O）。

---

# 🎯 **題意（重點）**

給一個由 `'X'` 和 `'O'` 組成的 board：

你要把 **被 X 完全包住** 的 `'O'` 變成 `'X'`。

但 **邊界上的 O** 以及所有與邊界 O 相連的 O，都不能被翻轉。

---

# 💡 **核心思路：從邊界開始 DFS/BFS（反向思考）**

因為：

- 被 X 包住的 O → 要翻成 X
- **不會被包住的 O** → 一定是從邊界出發，可以連到邊界

所以：

1. **掃描所有邊界的 O**
2. 連通區 DFS，把這些 O 改成 `'T'`（暫存）
3. 全圖遍歷
    - `'T'` → 邊界聯通 O → 換回 `'O'`
    - `'O'` → 被包住 → 改成 `'X'`

這是經典的 **反向標記法**。

---

# 📌 **完整流程圖**

```plain text
1. 從邊界開始 DFS，把所有可達的 O 標記成 T
2. 全圖掃描：
   T → O   (不被包住)
   O → X   (被包住)
```

---

# 🧠 **本題技巧**

- DFS 或 BFS 遍歷 grid
- 反向思考（找不能被包住的 O）
- 使用暫時字元避免覆蓋資訊
- Board in-place 修改

這題背下來後，可以秒殺同類 grid 題。

---

# 🧩 **程式碼解析（你的寫法）**

```python
class Solution:
    def solve(self, board: List[List[str]]) -> None:
        """
        Do not return anything, modify board in-place instead.
        """
        self.board = board

        # Step 1. DFS from all border cells
        for i in range(len(board)):
            self.dfs(i, 0)
            self.dfs(i, len(board[0])-1)

        for j in range(len(board[0])):  # 注意原本你多一個 s
            self.dfs(0, j)
            self.dfs(len(board)-1, j)

        # Step 2. Convert T back to O, and remaining O to X
        for i in range(len(board)):
            for j in range(len(board[0])):
                if board[i][j] == 'T':
                    board[i][j] = 'O'
                elif board[i][j] == 'O':
                    board[i][j] = 'X'

    def dfs(self, row, col):
        # Out of bound or not O → stop
        if row < 0 or col < 0 or row >= len(self.board) or col >= len(self.board[0]) \
            or self.board[row][col] != 'O':
            return

        # Mark as safe
        self.board[row][col] = 'T'

        # Explore neighbors
        self.dfs(row-1, col)
        self.dfs(row+1, col)
        self.dfs(row, col-1)
        self.dfs(row, col+1)


```

### ✔️ 你的寫法是標準解！

只需注意一個小 typo：`for j in range(len(board[0])):s` 多了 `s`。

---

# ⏱ **時間複雜度**

| 操作 | 次數 |
| --- | --- |
| 邊界 DFS | 最多 O(mn)（每格訪問一次） |
| 最後全圖掃描 | O(mn) |

### 👉 總時間：**O(mn)**

---

# 📦 **空間複雜度**

| 元件 | 空間 |
| --- | --- |
| recursion stack | 最差 O(mn)（全部為 O） |
| 額外空間 | in-place，無額外 grid |

### 👉 總空間：**O(mn)**（最差情況，由 DFS 決定）

若改 BFS，可降成 **O(min(m, n))**。

---

# 🔍 **是否有更好解法？**

| 方法 | 時間 | 空間 | 說明 |
| --- | --- | --- | --- |
| DFS（本題） | 🟢 O(mn) | 🔵 O(mn) | 最常見 |
| BFS | 🟢 O(mn) | 🟡 O(min(m, n)) | 遞迴爆 stack 的替代方案 |
| Union Find | 🔵 O(mn α(n)) | 🟡 O(mn) | 可行但不實用，比 DFS 麻煩 |

👉 **面試時建議 DFS or BFS，最快最乾淨。**

---

# 📝 **補充（面試容易被追問）**

可能的追問：

- 為什麼要從邊界開始？
- 為什麼不能從中間找被包住的區域？
- 用 BFS 怎麼寫？
- 可以不用暫存字元 T 嗎？
- 遞迴可能 stack overflow，要怎麼改？

---

# ✅ **總結（給 Notion 用）**

**解題關鍵：從邊界開始 DFS 標記 "安全的 O"，再翻轉剩下的 O。**

屬於經典 Grid 題，DFS/BFS 模板題，務必掌握。