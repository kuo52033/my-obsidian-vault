---
notion-id: 2a75a6e2-1812-8006-8660-f2ac3e39a640
---
### 1. 難度 (最高五星)

- **難度：** ★★☆☆☆ (2/5)
- **說明：** 這是一道 "Medium" 難度的題目。它不需要像 45. Jump Game II 那樣去計算「層數」(最少跳幾次)，它只問一個簡單的問題：「**辦得到嗎？(True/False)**」。

### 2. 核心技巧：貪心演算法 (Greedy Algorithm)

這題是貪心演算法的經典範例。

- **貪心策略：** 在每一步，我都「**盡我所能地更新我能跳到的最遠距離**」。
- **你的程式碼：** `farthest = max(farthest, nums[i] + i)` 這一行就是貪心策略的完美體現。

### 3. 核心邏輯分析 (你的程式碼)

你的程式碼非常簡潔且高效，我們來拆解：

- `**farthest = 0**`
    - **意義：** 記錄一個變數，代表「**到目前為止，我能到達的最遠索引**」。
- `**for i in range(len(nums)):**`
    - **意義：** 遍歷 `i` (當前位置)，你遍歷了*所有*的 `i` (從 0 到 `n-1`)。
- `**if farthest < i:**`
    - **意義：** 這是**最關鍵**的「**卡住**」判斷！
    - **白話文：** 如果我「當前站的位置 `i`」，已經**超過**了我「之前能到達的最遠距離 `farthest`」，這代表 `i` 是一個我**永遠到不了**的「孤島」。
    - **範例：** `[1, 0, 3]`
        - `i=0`: `farthest = 1`
        - `i=1`: `if 1 < 1` (False), `farthest = 1`
        - `i=2`: `if 1 < 2` (True), `**return False**`。(你甚至到不了 `i=2`)
    - 你的判斷 100% 正確。
- `**farthest = max(farthest, nums[i] + i)**`
    - **意義：** 更新「最遠能到達的距離」。如果我*能*站到 `i` (因為我沒被 `if` 擋住)，我就用 `nums[i] + i` 來更新我的最遠潛力。
- `**return farthest >= len(nums) - 1**`
    - **意義：** 當 `for` 迴圈*平安*跑完 (代表我們從未卡住，`i` 成功走到了 `n-1`)，我們只需要檢查，我們最終能到達的「最遠距離 `farthest`」，是否**大於或等於**「終點索引 `len(nums) - 1`」。
    - **(P.S. 其實**，如果你的迴圈能*平安*跑到 `i = n-1` 而沒有 `return False`，這就*已經*證明了 `farthest >= n-1`，所以你也可以直接 `return True`。但你寫的 `return farthest >= len(nums) - 1` 同樣 100% 正確！)

### 4. 與 45. Jump Game II 的關聯

你說的沒錯，這兩題是兄弟題。

- **45. Jump Game II (你寫的 $O(N)$ 解)：**
    - `farthest = max(farthest, nums[i] + i)`
    - `if i == curr_end:`
    - `jump += 1`
    - `curr_end = farthest`
    - **目標：** 它*假設*一定能到，它用 `farthest` 來「**預測**」下一層的邊界，用 `curr_end` 來「**觸發**」跳躍 (`jump += 1`)。
- **55. Jump Game I (你這題)：**
    - `if farthest < i: return False`
    - `farthest = max(farthest, nums[i] + i)`
    - **目標：** 它*不假設*一定能到，它用 `farthest` 來「**追蹤**」能到的邊界，並用 `if farthest < i` 來「**偵測**」是否掉隊。

你看，兩題的核心都是 `farthest = max(farthest, nums[i] + i)`，只是用這個 `farthest` 變數做了不同的事！

### 5. 時間與空間複雜度

1. **時間複雜度 (Time Complexity): $O(N)$**
    - $N$ 是 `nums` 陣列的長 độ。
    - 你只用了一個 `for` 迴圈，對陣列進行了**一次**完整的遍歷 (Single Pass)。
2. **空間複雜度 (Space Complexity): $O(1)$**
    - 你只使用了 `farthest` 一個額外變數，空間是固定的常數。

---

### 程式碼逐行說明 (你的程式碼)

Python

```python
class Solution:
    def canJump(self, nums: List[int]) -> bool:
        
        # 1. 初始化 "farthest"：
        #    代表 "到目前為止，我所能到達的最遠索引"
        farthest = 0

        # 2. 遍歷 nums 中的每一個索引 i
        for i in range(len(nums)):
            
            # 3. [關鍵] 檢查是否 "卡住"
            #    如果 "我當前的位置 i" 已經 "大於"
            #    "我理論上能到達的最遠位置 farthest"，
            #    表示 i 根本是個 "到不了" 的地方。
            if farthest < i:
                return False
                
            # 4. [核心] 貪心策略：
            #    更新 "最遠能到達的距離"
            #    取 "舊的最遠距離" 和 
            #    "從 i 這格跳出去的最遠距離 (nums[i] + i)"
            #    兩者中的較大值。
            farthest = max(farthest, nums[i] + i)
        
        # 5. [最終判斷]
        #    如果迴圈 "平安" 跑完 (從未卡住)，
        #    我們就成功了。
        #    (因為能跑到 i=n-1，就代表 farthest 至少 >= n-1)
        #    (你寫的 "farthest >= len(nums) - 1" 也是 100% 正確的)
        return True
```