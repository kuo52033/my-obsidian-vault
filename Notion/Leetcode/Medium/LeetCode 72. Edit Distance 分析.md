---
notion-id: 2a95a6e2-1812-80bb-9d8e-c1f54a944f64
---
### 1. 難度 (最高五星)

- **難度：** ★★★★☆ (4/5)
- **說明：** 這是 LeetCode 上的一道 "Hard" 題目。它不像「Unique Paths」(62 題) 那樣狀態轉移很直觀 ( `dp[i-1][j] + dp[i][j-1]` )。這題的難點在於要正確推導出當 `word1[i-1] != word2[j-1]` 時，`dp[i][j]` 應該是「插入」、「刪除」、「替換」這三種操作的*最小值*。

### 2. 運用到的技巧

1. **動態規劃 (Dynamic Programming - DP):**
    - 這是解法的核心。
2. **2D DP 表格 (2D DP Table):**
    - 你建立了一個 `(lenWord1 + 1) x (lenWord2 + 1)` 的表格來儲存所有子問題的解。`+ 1` 是為了處理「空字串」(`""`) 的基礎情況。

### 3. 核心邏輯分析 (你的 DP 解法)

**A. DP 狀態定義 (State Definition):**

- `dp[i][j]` 代表的意義是：
- 將 `word1` 的「前 `i` 個字元」(`word1[0...i-1]`) 轉換成 `word2` 的「前 `j` 個字元」(`word2[0...j-1]`) 所需要的「**最少操作次數**」。

B. 基礎情況 (Base Case):

你的 if i == 0: 和 if j == 0: 處理得非常漂亮。

- `**if i == 0: dp[i][j] = j**`
    - **意義：** `dp[0][j]` 代表將「空字串 `""`」轉換成 `word2` 的前 `j` 個字元 (例如 `"abc"`)。
    - **方法：** 唯一的方法就是執行 `j` 次「**插入 (Insert)**」操作。
- `**if j == 0: dp[i][j] = i**`
    - **意義：** `dp[i][0]` 代表將 `word1` 的前 `i` 個字元 (例如 `"abc"`) 轉換成「空字串 `""`」。
    - **方法：** 唯一的方法就是執行 `i` 次「**刪除 (Delete)**」操作。

C. 狀態轉移方程 (State Transition Equation):

這是整道題最精華的部分。

- `**if word1[i-1] == word2[j-1]:**`** (兩個字元相同)**
    - `dp[i][j] = dp[i-1][j-1]`
    - **意義：** (例如 `word1` = "hors**e**", `word2` = "ros**e**")。
    - 當前最後一個字元 `e` 相同，我們不需要做任何操作。所以「轉換 "horse" 到 "rose" 的成本」就等於「轉換 "hors" 到 "ros" 的成本」，即 `dp[i-1][j-1]`。
- `**if word1[i-1] != word2[j-1]:**`** (兩個字元不同)**
    - `dp[i][j] = min(dp[i-1][j-1] + 1, dp[i-1][j] + 1, dp[i][j-1] + 1)`
    - **意義：** (例如 `word1` = "hors**e**", `word2` = "ro**s**")。
    - 我們*必須*執行一次操作，但我們可以從三個「子問題」中選擇一個成本最低的來執行：
        1. `**dp[i-1][j-1] + 1**`** (替換 Replace):**
            - 我們先把 "hors" 轉成 "ro" (成本 `dp[i-1][j-1]`)。
            - 然後**替換**最後一個字元：'e' $\to$ 's' (成本 `+ 1`)。
        2. `**dp[i-1][j] + 1**`** (刪除 Delete):**
            - 我們先把 "hors" 轉成 "ros" (成本 `dp[i-1][j]`)。
            - 然後**刪除** `word1` 的最後一個字元 'e' (成本 `+ 1`)。
        3. `**dp[i][j-1] + 1**`** (插入 Insert):**
            - 我們先把 "horse" 轉成 "ro" (成本 `dp[i][j-1]`)。
            - 然後**插入** `word2` 的最後一個字元 's' (成本 `+ 1`)。
    - 你的程式碼取這三者的最小值，是完全正確的。

**D. 最終答案：**

- `return dp[lenWord1][lenWord2]` (即 `dp[m][n]`)
- **意義：** 返回「將*整個* `word1` 轉換成*整個* `word2`」的最小成本。

### 4. 時間與空間複雜度

- $M$ = `len(word1)`
- $N$ = `len(word2)`
3. **時間複雜度 (Time Complexity): $O(M \times N)$**
    - **分析：** 你使用了兩個巢狀 `for` 迴圈，遍歷了 `(M + 1) x (N + 1)` 網格中的**每一個**格子*一次*。
4. **空間複雜度 (Space Complexity): $O(M \times N)$**
    - **分析：** 你需要一個大小為 `(M + 1) x (N + 1)` 的 `dp` 陣列來儲存所有子問題的狀態。
    - (P.S.
這題的空間可以被優化到 $O(\min(M, N))$，因為你每次計算 dp[i][j] 時，其實只需要 dp[i-1] (上一行) 和 dp[i] (當前行) 的數據。)

---

### 5. 程式碼逐行說明 (你的程式碼)

Python

```python
class Solution:
    def minDistance(self, word1: str, word2: str) -> int:
        lenWord1 = len(word1)
        lenWord2 = len(word2)
        
        # 1. 建立 DP 表，大小 (m+1) x (n+1)
        #    dp[i][j] = word1[0...i-1] 轉到 word2[0...j-1] 的成本
        dp = [[0] * (lenWord2 + 1) for _ in range(lenWord1 + 1)]

        # 2. 遍歷 m+1 行
        for i in range(lenWord1 + 1):
            # 3. 遍歷 n+1 列
            for j in range(lenWord2 + 1):
                
                # 4. [基礎情況 1]：
                #    i=0 (空字串 "" 轉到 "abc")，需要 j 次 "插入"
                if i == 0:
                    dp[i][j] = j
                    continue
                
                # 5. [基礎情況 2]：
                #    j=0 ("abc" 轉到空字串 "")，需要 i 次 "刪除"
                if j == 0:
                    dp[i][j] = i
                    continue

                # 6. [狀態轉移 1：字元相同]
                #    (注意 i-1 和 j-1，因為 dp 索引比 string 索引多 1)
                if word1[i-1] == word2[j-1]:
                    # 不需操作，成本 = 轉換 "前面子字串" 的成本
                    dp[i][j] = dp[i-1][j-1]
                
                # 7. [狀態轉移 2：字元不同]
                else:
                    # 成本 = 1 (操作一次) + 三種可能中的最小值
                    dp[i][j] = min(
                        dp[i-1][j-1] + 1, # 替換 (Replace)
                        dp[i-1][j] + 1,   # 刪除 (Delete)
                        dp[i][j-1] + 1    # 插入 (Insert)
                    )
        
        # 8. 返回 "整個 word1" 轉到 "整個 word2" 的成本
        return dp[lenWord1][lenWord2]
```