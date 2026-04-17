---
notion-id: 2985a6e2-1812-8039-9879-ea10bb4cf6e6
---
### 1. 難度 (最高五星)

- **難度：** ★★★☆☆ (3/5)
- **說明：** 這是一道 "Medium" 難度的題目。它不像前幾題有巧妙的數學或指針技巧，而是紮實地考察你**設計遞迴函式來「窮舉所有可能性」**的能力。

### 2. 運用到的技巧

1. **回溯演算法 (Backtracking):**
    - 這是你解法的核心。回溯法是「深度優先搜索 (DFS)」的一種，專門用來解決「組合」、「排列」、「子集」等窮舉所有可能性的問題。
    - 你的 `combine` 函式就是一個標準的回溯函式。
2. **遞迴 (Recursion):**
    - 你的遞迴設計很棒，有清晰的「基礎情況 (Base Case)」和「遞迴步驟 (Recursive Step)」。
    - 你的 `combine(self, s, digits)` 函式完美地展示了回溯的三個步驟：
        - **1. 選擇 (Choose):** `for d in self.hash[digits[0]]`
            - 你在 `digits[0]` (例如 "2") 對應的字母 `["a", "b", "c"]` 中做出「選擇」。
        - **2. 探索 (Explore):** `self.combine(s + d, digits[1:])`
            - 你帶著這個選擇 (`s + d`)，去「探索」剩下的問題 (`digits[1:]`)，進入更深一層的遞迴。
        - **3. 回溯 (Un-choose / Backtrack):**
            - 你的寫法很巧妙。當 `self.combine("a", "3")` 這條路徑探索完畢並返回時，`for` 迴圈會自動進入下一個 `d = "b"`。
            - 因為你傳遞的是 `s + d` (一個*新的*字串)，而不是在原地修改 `s`，所以你不需要手動「撤銷」選擇。`for` 迴圈本身就完成了「回溯」的效果。

### 3. 程式碼分析 (含一個小小的修正)

你的程式碼邏輯 100% 正確，但只差一個小小的**邊界情況 (Edge Case)**：

**問題：** 當輸入 `digits` 本身就是空字串 `""` 時。

3. `letterCombinations("")` 被呼叫。
4. `self.combine("", "")` 被呼叫。
5. 在 `combine` 中，`if digits == ""` 條件成立。
6. `self.result.append(s)` (此時 `s` 是 `""`)。
7. `self.result` 變成了 `[""]`。
8. 最後返回 `[""]`。

**但是，LeetCode 題目要求輸入 **`**""**`** 時，應返回 **`**[]**`** (一個空列表)。**

修正方法：

你只需要在主函式 letterCombinations 的最開頭加一個判斷：

Python

```python
class Solution:
    def letterCombinations(self, digits: str) -> List[str]:
        
        # --- 修正 ---
        # 處理
        if not digits: # 或是 if len(digits) == 0:
            return []
        # --- 修正結束 ---

        self.hash = {
            "2": ["a", "b", "c"],
            "3": ["d", "e", "f"],
            "4": ["g", "h", "i"],
            "5": ["j", "k", "l"],
            "6": ["m", "n", "o"],
            "7": ["p", "q", "r", "s"],
            "8": ["t", "u", "v"],
            "9": ["w", "x", "y", "z"],
        }
        self.result = []

        self.combine("", digits)

        return self.result

    def combine(self, s, digits):
        # 基礎情況 (Base Case)
        # 當 digits 已經沒有數字了，表示 s 是一個完整的組合
        if digits == "":
            self.result.append(s)
            return
        
        # 遞迴步驟 (Recursive Step)
        # 1. 取得第一個數字 (digits[0]) 對應的字母 (例如 ["a", "b", "c"])
        current_letters = self.hash[digits[0]]
        
        # 2. 選擇 (Choose)
        for d in current_letters:
            # 3. 探索 (Explore)
            # 帶著 "目前的字串 + 新選擇的字母" (s + d)
            # 繼續處理 "剩下的數字" (digits[1:])
            self.combine(s + d, digits[1:])
```

加上那個判斷之後，你的程式碼就完美了！

### 4. 時間與空間複雜度

- $N$ = `digits` 字串的長度。
- $k$ = 每個數字平均代表的字母數（平均是 3，最大是 4，我們取 $k=4$）。
9. **時間複雜度 (Time Complexity): $O(N \times 4^N)$**
    - **$4^N$ 是怎麼來的？**
        - 你的遞迴會產生一個「決策樹」。
        - 總共有 $N$ 層 ( `digits` 的長度)。
        - 每一層最多有 4 個分支 (例如 "7" 或 "9")。
        - 最終「葉節點」(也就是答案) 的數量大約是 $O(4^N)$ 個。
    - **$N$ 是怎麼來的？**
        - 每個答案的長度是 $N$。當你到達葉節點並 `append(s)` 時，`s + d` 這個字串相加的操作，在 $N$ 層遞迴中累計起來的成本是 $O(N)$。
        - 總共有 $O(4^N)$ 個解，每個解的產生過程成本是 $O(N)$，所以總時間是 $O(N \times 4^N)$。
10. **空間複雜度 (Space Complexity): $O(N)$**
    - 這裡我們*不*計算 `result` 輸出陣列本身佔用的空間。
    - 空間複雜度主要來自遞迴所需的「**函式呼叫堆疊 (Call Stack)**」。
    - 你的遞迴 `self.combine` 最多會呼叫自己 $N$ 次 (樹的深度，例如 `digits = "234"`，會呼叫 3 層)。
    - 因此，呼叫堆疊的最大深度是 $O(N)$。