---
notion-id: 2995a6e2-1812-806b-897e-d68a81dc1836
---
### 1. 難度 (最高五星)

- **難度：** ★★★☆☆ (3/5)
- **說明：** 這是一道 "Medium" 難度的經典回溯題。它考察的是你如何「窮舉」所有可能性，同時聰明地「剪枝」(Pruning) 掉所有不合法的路徑。

### 2. 運用到的技巧

1. **回溯演算法 (Backtracking):**
    - 你的 `combine` 函式就是一個回溯函式，它會像在迷宮中探索一樣，嘗試所有可能的路徑 (放 `(` 或 `)`)。
2. **狀態變數 (State Tracking):**
    - 你用了三個變數來完美追蹤當前的狀態：
        - `s`：當前正在組合的字串。
        - `open_used`：**已經使用**了多少個 `(` (左括號)。
        - `close_used`：**已經使用**了多少個 `)` (右括號)。
3. **剪枝 (Pruning):**
    - `if open_used < self.total:` 和 `if open_used > close_used:` 這兩行就是「剪枝」的關鍵。你只在「合法」的前提下才繼續往下探索，大大減少了計算量。

### 3. 核心邏輯分析 (你的程式碼)

你的 `combine` 函式有三個關鍵判斷，這正是本題的精髓：

4. **基礎情況 (Base Case):**
    - `if len(s) == self.total * 2:`
    - **意義：** 當字串 `s` 的長度達到了 $n \times 2$ (例如 $n=3$，長度 6)，表示一個完整的組合已經產生。我們將它存入 `self.result` 並結束 (return) 這一層的探索。
5. **規則 1：加入 **`**(**`** 的時機**
    - `if open_used < self.total:`
    - **意義：** 這是「黃金定律一」。只要我手上 `(` 的*使用量*還沒達到*總額度* $n$，我就可以*隨時*放一個 `(`。
    - **遞迴：** `self.combine(s + "(", open_used + 1, close_used)`
        - 你正確地傳遞了新狀態：字串加上 `(`，且 `open_used` 計數器加 1。
6. **規則 2：加入 **`**)**`** 的時機**
    - `if open_used > close_used:`
    - **意義：** 這是「黃金定律二」，也是**合法性**的關鍵。我**只能**在「*已經*放的 `(` 數量」**大於**「*已經*放的 `)` 數量」時，才能放一個 `)`。
    - **原因：** 這確保了 `)` 永遠都有一個在它左邊的 `(` 可以跟它配對，防止了 `")("` 或 `")()"` 這種非法情況。
    - **遞迴：** `self.combine(s + ")", open_used, close_used + 1)`
        - 你正確地傳遞了新狀態：字串加上 `)`，且 `close_used` 計數器加 1。

### 4. 時間與空間複雜度

7. **時間複雜度 (Time Complexity): $O(\frac{4^n}{\sqrt{n}})$**
    - 這是一個「卡特蘭數」(Catalan Number) 的結果，你不需要死記。
    - 你可以粗略地理解為 $O(4^N)$ (一個寬鬆的上限)，因為在每一步，你最多有 2 個選擇 (放 `(` 或 `)`)，樹的深度最多是 $2N$ (雖然很多分支會被 `if` 規則剪掉)。
    - 每個答案的長度是 $2N$，產生答案也需要成本。
8. **空間複雜度 (Space Complexity): $O(N)$**
    - 這裡我們*不*計算 `result` 輸出陣列本身佔用的空間。
    - 空間成本主要來自遞迴所需的「**函式呼叫堆疊 (Call Stack)**」。
    - 你的遞迴深度最深就是 $2N$ (字串的總長度)，所以空間複雜度是 $O(N)$。

---

### 程式碼逐行說明 (你的程式碼)

Python

```python
class Solution:
    def generateParenthesis(self, n: int) -> List[str]:
        # 1. 初始化結果列表
        self.result = []
        # 2. 將 n 存為全域變數，方便遞迴函式取用
        self.total = n

        # 3. 開始回溯
        # s=""         (當前字串為空)
        # open_used=0  (已用 0 個 '(')
        # close_used=0 (已用 0 個 ')')
        self.combine("", 0, 0)

        # 6. 返回最終所有合法的組合
        return self.result
    
    def combine(self, s, open_used, close_used):
        
        # 4. 基礎情況 (Base Case)：
        # 當字串長度等於 n*2 時，表示一個組合已完成
        if len(s) == self.total * 2:
            self.result.append(s)
            return
        
        # 5. 遞迴探索 (帶有 "剪枝" 條件)
        
        # --- 規則一：放 '(' ---
        # 只要已用的 '(' 數量還沒達到總額度 n
        if open_used < self.total:
            # 就繼續探索 "放了 '('" 的這條路
            self.combine(s + "(", open_used + 1, close_used)
        
        # --- 規則二：放 ')' ---
        # 只要已用的 '(' 數量 "大於" 已用的 ')' 數量
        # (這保證了 ')' 永遠有 '(' 可以配對)
        if open_used > close_used:
            # 就繼續探索 "放了 ')'" 的這條路
            self.combine(s + ")", open_used, close_used + 1)
```