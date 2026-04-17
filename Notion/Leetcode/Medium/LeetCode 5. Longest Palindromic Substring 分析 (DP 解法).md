---
notion-id: 2955a6e2-1812-80f5-8323-d7dfc1ae94ce
---
### 1. 難度 (最高五星)

- **難度：** ★★★☆☆ (3/5)
- **說明：** 這是一題經典的 "Medium" 難度題目。它的難點在於需要想到使用「動態規劃」來儲存子問題的狀態，或者使用「中心擴展法」。相較於第 3 題的滑動窗口，DP 的狀態定義和狀態轉移需要更抽象的思考。你採用的 DP 解法是非常標準且穩健的。

### 2. 運用到的技巧

1. **動態規劃 (Dynamic Programming - DP):**
    - 這是你解法的核心。你利用「子字串是否為迴文」這個特性，將大問題分解為小問題。
2. **狀態定義 (State Definition):**
    - 你建立了一個 2D 陣列 `dp[j][i]`。
    - `dp[j][i]` 代表的意義是：**從索引 **`**j**`** 到索引 **`**i**`** 的子字串 **`**s[j...i]**`** 是否為一個迴文**。
    - 你用 `True` (或 `1`) 來表示「是」，`False` (或 `0`) 來表示「否」。
3. **狀態轉移方程 (State Transition Equation):**
    - 這是 DP 最關鍵的部分。你將其分為三種情況：
    - **基礎情況 1 (長度為 1):** `if i == j:`
        - `dp[j][i] = True` (單一字元必為迴文)
    - **基礎情況 2 (長度為 2):** `elif i - j == 1:`
        - `dp[j][i] = (s[i] == s[j])` (兩個字元必須相同)
    - **遞迴情況 (長度 > 2):** `else:`
        - `dp[j][i] = (s[i] == s[j] and dp[j+1][i-1])`
        - (外層字元 `s[i]` 和 `s[j]` 必須相同，*而且* 它的內層子字串 `s[j+1...i-1]` 也必須是迴文)
4. **結果追蹤 (Answer Tracking):**
    - 你使用了 `maxLeft` 和 `maxRight` 兩個變數。
    - 在每次計算出 `dp[j][i] = True` 時，你都檢查 `i - j` (當前長度 - 1) 是否大於 `maxRight - maxLeft` (已知的最長長度 - 1)，並即時更新最長迴文的左右邊界。

### 3. 時間與空間複雜度

5. **時間複雜度 (Time Complexity): $O(N^2)$**
    - $N$ 是輸入字串 `s` 的長度。
    - 分析：你的程式碼使用了兩個巢狀迴圈。外層 `i` 跑 $N$ 次，內層 `j` 平均跑 $N/2$ 次 (從 `0` 到 `i`)。
    - `dp` 表格中總共有 $N \times N$ 個狀態，你填滿了其中大約一半的格子 ( `j <= i` 的部分)，每次填格子的操作 (判斷) 都是 $O(1)$ 的。
    - 因此，總時間複雜度為 $O(N^2)$。
6. **空間複雜度 (Space Complexity): $O(N^2)$**
    - $N$ 是輸入字串 `s` 的長度。
    - 分析：你需要一個 $N \times N$ 的 `dp` 表格來儲存所有子問題的狀態。

### 4. 程式碼逐行說明

這就是你剛剛提供的程式碼，我幫你加上了詳細的註解：

Python

```python
class Solution:
    def longestPalindrome(self, s: str) -> str:
        # 1. 初始化
        length = len(s)
        
        # 建立 DP 表格
        # dp[j][i] 表示 s[j...i] 是否為迴文
        # (你用 0 和 True/False 混用，功能上是 OK 的，
        #  因為 if 0 == False 且 if 1 == True，但建議統一用 Boolean)
        dp = [[0] * length for _ in range(length)]
        
        # maxLeft 和 maxRight 用來記錄目前找到的最長迴文的 "起始" 和 "結束" 索引
        maxLeft, maxRight = 0, 0

        # 2. 填寫 DP 表格
        # 外層迴圈 i (結束索引)，從 0 跑到 length-1
        for i in range(length):
            # 內層迴圈 j (起始索引)，從 0 跑到 i
            # 這個順序確保在計算 dp[j][i] 時，
            # 它所依賴的 dp[j+1][i-1] 已經被計算過了
            for j in range(i+1):
                
                # 情況一：基礎情況 (長度為 1)
                # s[i...i]
                if i == j:
                    dp[j][i] = True
                
                # 情況二：基礎情況 (長度為 2)
                # s[j...i] (例如 s[0...1])
                elif i - j == 1:
                    dp[j][i] = True if s[i] == s[j] else False
                
                # 情況三：遞迴情況 (長度 > 2)
                else:
                    # 必須 (1) 外層字元相同 s[i] == s[j]
                    # 並且 (2) 內層子字串 dp[j+1][i-1] 也必須是迴文
                    dp[j][i] = True if s[i] == s[j] and dp[j+1][i-1] == True else False
                
                # 3. 檢查並更新最長迴文
                # 如果 dp[j][i] 被證實為迴文
                # 且 當前長度 (i - j) 大於 已記錄的最長長度 (maxRight - maxLeft)
                if dp[j][i] == True and i - j > maxRight - maxLeft:
                    # 更新最長迴文的邊界
                    maxLeft, maxRight = j, i
        
        # 4. 返回結果
        # 根據儲存的左右邊界，從原字串 s 中切片
        # 注意：Python 切片 s[start:end] 不包含 end，所以要 maxRight + 1
        return s[maxLeft:maxRight+1]
```