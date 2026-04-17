---
notion-id: 2a45a6e2-1812-802b-aee6-dae6ebe506c0
---
### 1. 難度 (最高五星)

- **難度：** ★★☆☆☆ (2/5)
- **說明：** 這是一道 "Medium" 難度的題目。它不考察高深的演算法 (如 DP、回溯)，而是紮實地考察你「**模擬 (Simulation)**」的能力，以及你對「**邊界條件**」的處理是否夠細心。

### 2. 運用到的技巧

1. **邊界指針 (Boundary Pointers):**
    - 這是你解法的核心。你使用了 `top`, `bottom`, `left`, `right` 四個變數，精確地定義了「尚未處理」的矩陣範圍。
2. **模擬 (Simulation):**
    - 你的 `while` 迴圈就是在模擬「螺旋」的過程，透過依序執行「向右、向下、向左、向上」四個動作，並在每一步之後「**收縮邊界**」。

### 3. 核心邏輯分析 (你的程式碼)

你的程式碼完美地執行了「剝洋蔥」的四個步驟：

3. `**while top <= bottom and left <= right:**`
    - 這是迴圈的「繼續」條件。只要「上/下邊界」還沒交叉，且「左/右邊界」還沒交叉，就表示中間還有元素要處理。
4. `**for column in range(left, right+1):**`** (向右走)**
    - 遍歷最上面 (`top`) 的一行。
    - **更新：** `top += 1` (最上面一行處理完畢，邊界向下收縮)。
5. `**for row in range(top, bottom+1):**`** (向下走)**
    - 遍歷最右邊 (`right`) 的一列。
    - **更新：** `right -= 1` (最右邊一列處理完畢，邊界向左收縮)。
6. `**if top > bottom or right < left: break**`** (最精妙之處！)**
    - **意義：** 這是在處理「**單行**」或「**單列**」矩陣的**關鍵**。
    - **範例 (單行)：** `[[1, 2, 3]]`
        - `top=0, bottom=0, left=0, right=2`
        - **步驟 1 (向右)：** `result` 加入 `[1, 2, 3]`。
        - **更新 1：** `top` 變成 `1`。
        - **步驟 2 (向下)：** `range(top, bottom+1)` 變成 `range(1, 1)`，迴圈*不會*執行 (正確)。
        - **更新 2：** `right` 變成 `1`。
        - **檢查：** `if top > bottom ...` ( `1 > 0` ) $\to$ **True**。
        - `**break**` (迴圈提前終止)。
    - **如果不加這個 **`**break**`**：** 步驟 3 (向左走) 會執行 `range(1, -1, -1)`，試圖讀取 `matrix[bottom][...]` (即 `matrix[0]...`)，導致重複讀取 `[2, 1]`。
    - 你的這個檢查，完美地防止了這種重複。
7. `**for column in range(right, left-1, -1):**`** (向左走)**
    - 遍歷最下面 (`bottom`) 的一行 (倒序)。
    - **更新：** `bottom -= 1` (最下面一行處理完畢，邊界向上收縮)。
8. `**for row in range(bottom, top -1, -1):**`** (向上走)**
    - 遍歷最左邊 (`left`) 的一列 (倒序)。
    - **更新：** `left += 1` (最左邊一列處理完畢，邊界向右收縮)。

### 4. 時間與空間複雜度

- $M$ = 矩陣的「行數」 (rows)
- $N$ = 矩陣的「列數」 (columns)
9. **時間複雜度 (Time Complexity): $O(M \times N)$**
    - **分析：** 你的演算法會「**不重複地**」訪問矩陣中的*每一個*元素*一次*。
10. **空間複雜度 (Space Complexity): $O(1)$ (不含輸出)**
    - **分析：** 你只使用了 `top`, `bottom`, `left`, `right` 等幾個常數空間的變數。
    - (如果你把 `result` 列表也算進去，那空間複雜度就是 $O(M \times N)$，因為它儲存了所有元素。但在演算法分析中，我們通常指的是「**輔助空間 (Auxiliary Space)**」。)

---

### 程式碼逐行說明 (你的程式碼)

Python

```python
class Solution:
    def spiralOrder(self, matrix: List[List[int]]) -> List[int]:
        
        # 1. 初始化 "尚未處理" 的四個邊界
        top = 0
        bottom = len(matrix) - 1
        left = 0
        right = len(matrix[0]) - 1
        
        result = [] # 儲存結果

        # 2. 只要 "上下邊界" 或 "左右邊界" 還沒交叉，就繼續
        while top <= bottom and left <= right:
            
            # --- 步驟 1: 向右走 (遍歷 top 行) ---
            for column in range(left, right+1):
                result.append(matrix[top][column])
            # "top" 行已處理完，邊界下移
            top += 1
            
            # --- 步驟 2: 向下走 (遍歷 right 列) ---
            for row in range(top, bottom+1):
                result.append(matrix[row][right])
            # "right" 列已處理完，邊界左移
            right -= 1

            # --- 關鍵檢查：處理 "單行" 或 "單列" ---
            # (在 "向左" 和 "向上" 之前檢查)
            if top > bottom or right < left:
                break

            # --- 步驟 3: 向左走 (遍歷 bottom 行) ---
            # (倒序：從 right 走到 left)
            for column in range(right, left-1, -1):
                result.append(matrix[bottom][column])
            # "bottom" 行已處理完，邊界上移
            bottom -= 1

            # --- 步驟 4: 向上走 (遍歷 left 列) ---
            # (倒序：從 bottom 走到 top)
            for row in range(bottom, top -1, -1):
                result.append(matrix[row][left])
            # "left" 列已處理完，邊界右移
            left += 1
        
        # 5. 返回結果
        return result
```