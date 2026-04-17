---
notion-id: 2aa5a6e2-1812-80d6-baca-f0b74dfd32e4
---
### 1. 難度 (最高五星)

- **難度：** ★★☆☆☆ (2/5)
- **說明：** 這是一道 "Medium" 難度的題目。它考察的是你對「二分搜尋法」的理解，以及你是否能發現這題的**關鍵屬性**。

### 2. 運用到的技巧

1. **二分搜尋法 (Binary Search):**
    - 這是解題的核心演算法。
2. **2D 轉 1D 索引 (2D-to-1D Index Mapping):**
    - 這是這題的「**技巧**」。你把一個 2D 的 `(row, col)` 索引，和一個 1D 的 `mid` 索引，完美地對應了起來。

### 3. 核心邏輯分析 (你的程式碼)

這題的矩陣有兩個關鍵屬性：

3. 每一行 (row) 都是**由左到右**排序的。
4. 下一行的**第一個數** > 上一行的**最後一個數**。

**這兩個屬性保證了：** 如果你把這個 2D 矩陣「**攤平**」，它會是一個**單一且連續的已排序 1D 陣列**。

你的演算法正是利用了這個特性：

5. **「虛擬」的 1D 陣列：**
    - `n_rows = len(matrix)`, `n_cols = len(matrix[0])`
    - `left = 0` (虛擬 1D 陣列的「頭」)
    - `right = n_rows * n_cols - 1` (虛擬 1D 陣列的「尾」)
    - 你在 `[0, M*N - 1]` 這個範圍內進行二分搜尋。
6. **「虛擬 1D 索引」轉「真實 2D 索引」(最精華的部分)：**
    - `mid = (left + right) // 2`
        - `mid` 是 `0` 到 `M*N - 1` 之間的一個「虛擬索引」。
    - `row = mid // n_cols`
        - **意義：** `mid` 索引中，可以「塞滿」多少個「完整的行」？`n_cols` (列數) 代表一行的寬度。 `mid // n_cols` 完美地算出了 `mid` 落在第幾行。
    - `col = mid % n_cols`
        - **意義：** 在塞滿了 `row` 這麼多行之後，「剩下的餘數」就是它在該行中的「列索引」。
7. **標準二分搜尋：**
    - `if matrix[row][col] == target:` (找到！)
    - `if matrix[row][col] >= target:` (因為 `==` 已經被 `return`，所以這裡等於 `>`)
        - **意義：** `mid` 的值太大了，`target` 應該在左半邊。
        - `right = mid - 1`
    - `else:` ( `matrix[row][col] < target` )
        - **意義：** `mid` 的值太小了，`target` 應該在右半邊。
        - `left = mid + 1`

### 4. 時間與空間複雜度

- $M$ = 矩陣的「行數」 (rows)
- $N$ = 矩陣的「列數」 (columns)
8. **時間複雜度 (Time Complexity): $O(\log(M \times N))$**
    - **分析：** 你在一個總大小為 $M \times N$ 的「虛擬陣列」上執行了一次標準的二分搜尋法。
    - ( `log(M*N)` 也可以寫成 `log(M) + log(N)` )
9. **空間複雜度 (Space Complexity): $O(1)$**
    - **分析：** 你只使用了 `left`, `right`, `mid`, `row`, `col` 幾個變數，空間是固定的常數。

---

### 程式碼逐行說明 (你的程式碼)

Python

```python
class Solution:
    def searchMatrix(self, matrix: List[List[int]], target: int) -> bool:
        
        n_rows = len(matrix)
        n_cols = len(matrix[0])
        
        # 1. 建立 "虛擬 1D 陣列" 的左右邊界
        left = 0
        right = n_rows * n_cols - 1

        while left <= right:
            # 2. 取得 "虛擬 1D 索引" mid
            mid = (left + right) // 2
            
            # 3. [核心] 將 "1D 索引" 轉回 "2D 索引"
            #    n_cols 是 "一行的寬度"
            row = mid // n_cols  # (mid 除以 寬度 = 第幾行)
            col = mid % n_cols   # (mid 對 寬度 取餘 = 第幾列)

            # 4. 標準的二分搜尋邏輯
            if matrix[row][col] == target:
                return True
            
            # (因為 "==" 已 return，所以這裡等同於 >)
            if matrix[row][col] >= target:
                right = mid - 1 # 往左半邊搜
            else:
                left = mid + 1  # 往右半邊搜
        
        # 5. 迴圈跑完都沒找到
        return False
```