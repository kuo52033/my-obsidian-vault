---
notion-id: 2a95a6e2-1812-80cd-bbe6-d8fca8d1286d
---
### 1. 難度 (最高五星)

- **難度：** ★★★☆☆ (3/5)
- **說明：** 這道 "Medium" 題的 $O(M+N)$ 解法是 ★★☆☆☆，但 $O(1)$ 的解法絕對有 ★★★☆☆。
- **難點：** 如何在不使用額外 `set` 或陣列的情況下，「記住」哪些行/列需要被清零，同時又**不污染**原始矩陣中尚未被檢查的 0。

### 2. 核心技巧：使用「第一行」和「第一列」作為標記空間

你的解法非常巧妙，你意識到我們不需要 $O(M+N)$ 的*額外*空間，我們可以「**借用**」矩陣**本身的第一行和第一列**來充當我們的 `row` set 和 `col` set。

- `matrix[i][0] = 0` $\to$ 代表「第 `i` 行」需要被清零。
- `matrix[0][j] = 0` $\to$ 代表「第 `j` 列」需要被清零。

### 3. 核心邏輯分析 (你寫法的精妙之處)

**A. 最大的陷阱 (你完美避開了)：**

- `matrix[0][0]` 這個格子有「雙重身分」。它既代表「第一行」需要清零，也代表「第一列」需要清零。
- 如果你在標記時，`matrix[1][1] == 0` $\to$ `matrix[1][0]=0`, `matrix[0][1]=0`。但如果 `matrix[0][0]` *一開始就是 0*，你怎麼知道是它自己是 0，還是被別人標記的？

B. 你的解決方案 (4 個步驟)：

你的程式碼完美地透過 4 個步驟解決了這個問題：

- **步驟 1：(前置作業) 儲存「邊界」的原始狀態**
    - `firstRowZero = False`
    - `firstColZero = False`
    - 你用了兩個 $O(1)$ 的布林變數，**專門**用來儲存「第一行」和「第一列」*一開始*是否就包含 0。
- **步驟 2：(標記 Pass 1) 遍歷「內部」矩陣，標記「邊界」**
    - `for i in range(1, ...`
    - `for j in range(1, ...`
    - 你**跳過**第一行/第一列，只遍歷內部。
    - `if matrix[i][j] == 0:`，你就去「標記」`matrix[i][0] = 0` 和 `matrix[0][j] = 0`。
    - **重點：** 這一步*不會*污染 `firstRowZero` 和 `firstColZero` 變數。
- **步驟 3：(執行 Pass 2) 根據「標記」清零「內部」**
    - `for i in range(1, ...`
    - `for j in range(1, ...`
    - 你再次遍歷內部。
    - `if matrix[i][0] == 0 or matrix[0][j] == 0:`，就把 `matrix[i][j] = 0`。
- **步驟 4：(收尾 Pass 3) 根據「原始狀態」清零「邊界」**
    - `if firstRowZero: ...`
    - `if firstColZero: ...`
    - 在所有工作都完成後，你才回過頭來，根據*一開始*儲存的 `boolean` 狀態，決定是否清零第一行和第一列。

### 4. 時間與空間複雜度

- $M$ = 矩陣的「行數」 (rows)
- $N$ = 矩陣的「列數」 (columns)
1. **時間複雜度 (Time Complexity): $O(M \times N)$**
    - **分析：** 你的程式碼看起來有很多 `for` 迴圈，但我們來加總：
        - 步驟 1 (檢查邊界)： $O(M) + O(N)$
        - 步驟 2 (標記內部)： $O(M \times N)$
        - 步驟 3 (清零內部)： $O(M \times N)$
        - 步驟 4 (清零邊界)： $O(M) + O(N)$
    - **總和：** $O(2 \times (M \times N) + 2 \times (M + N))$，取最高項，仍為 **$O(M \times N)$**。
2. **空間複雜度 (Space Complexity): $O(1)$**
    - **分析：** 你**沒有**使用任何大小與 `M` 或 `N` 相關的額外空間。
    - 你只使用了 `firstRowZero` 和 `firstColZero` 兩個布林變數，這是**常數空間**！

---

### 程式碼逐行說明 (你的程式碼)

Python

```python
class Solution:
    def setZeroes(self, matrix: List[List[int]]) -> None:
        
        # --- 步驟 1: 檢查 "第一行" 和 "第一列" 的原始狀態 ---
        
        firstRowZero = False
        firstColZero = False

        # 檢查 "第一列" (Column 0) 是否有 0
        for i in range(len(matrix)):
            if matrix[i][0] == 0:
                firstColZero = True
                break

        # 檢查 "第一行" (Row 0) 是否有 0
        for j in range(len(matrix[0])):
            if matrix[0][j] == 0:
                firstRowZero = True
                break

        # --- 步驟 2: (Pass 1) 遍歷 "內部"，"標記" 第一行/第一列 ---
        
        for i in range(1, len(matrix)):
            for j in range(1, len(matrix[0])):
                # 如果 "內部" (i, j) 是 0
                if matrix[i][j] == 0:
                    # 就用 (i, 0) 和 (0, j) 當作 "標記"
                    matrix[0][j] = 0
                    matrix[i][0] = 0
        
        # --- 步驟 3: (Pass 2) 根據 "標記"，清零 "內部" ---
        
        for i in range(1, len(matrix)):
            for j in range(1, len(matrix[0])):
                # 如果 (i, j) 對應的 "行標記" 或 "列標記" 是 0
                if matrix[i][0] == 0 or matrix[0][j] == 0:
                    # 就清零 "內部" (i, j)
                    matrix[i][j] = 0
        
        # --- 步驟 4: (Pass 3) 根據 "原始狀態"，清零 "邊界" ---
        
        # 如果 "第一行" *本來* 就有 0
        if firstRowZero:
            for j in range(len(matrix[0])):
                matrix[0][j] = 0
        
        # 如果 "第一列" *本來* 就有 0
        if firstColZero:
            for i in range(len(matrix)):
                matrix[i][0] = 0
```