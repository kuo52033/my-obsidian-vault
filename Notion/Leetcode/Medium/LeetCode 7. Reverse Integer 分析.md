---
notion-id: 2955a6e2-1812-8080-926c-d10eb6e74054
---
### 1. 難度 (最高五星)

- **官方難度：** ★☆☆☆☆ (Easy)
- **陷阱難度：** ★★☆☆☆ (Easy 體感，Medium 陷阱)
- **說明：** 題目的核心邏輯（數字反轉）很簡單，但真正的考點在於如何處理 32-bit 帶符號整數的範圍限制 $[-2^{31}, 2^{31} - 1]$。

### 2. 運用到的技巧

1. **數字操作 (Digit Manipulation):**
    - 你使用了「取餘數 `%`」和「整數除法 `//`」的組合技。
    - `x % 10`：取得 (pop) $x$ 的最後一位數字。
    - `x // 10`：從 $x$ 身上移除最後一位數字。
    - `result * 10 + ...`：將新數字推入 (push) 到 `result` 的尾端。
    - 這是處理整數各位數字的標準演算法。
2. **邊界條件處理 (Edge Case Handling):**
    - **符號 (Sign):** 你使用 `negative` 變數先把符號存起來，用 `abs(x)` (或 `x = -x`) 的方式簡化主迴圈邏輯。這是非常好的習慣。
    - **溢位 (Overflow):** 這是本題的**核心陷阱**。

### 3. 溢位 (Overflow) 的處理方式

這也是你程式碼最巧妙的地方。在 C++/Java 中，`result` 變數本身在 `result *= 10` 時就可能溢位，導致程式崩潰或得到錯誤答案。他們必須在 *計算前* 就檢查 `result` 是否 *即將* 溢位。

但在 **Python** 中，`int` 類型是**不會溢位**的（它可以儲存任意大的整數）。

- 你的策略是：**「先讓它算，最後再檢查。」**
- 你讓 Python 自由地計算出 `result`，哪怕這個 `result` 已經是 `98765432199` (遠超 32-bit 範圍)。
- 直到最後 `return` 的時候，你才用一行 `if -2**31 <= result <= 2**31 - 1 else 0` 來判斷這個「最終結果」是否在 32-bit 的合法範圍內。
- 這充分利用了 Python 語言的特性，讓程式碼變得非常乾淨易懂。

### 4. 時間與空間複雜度

3. **時間複雜度 (Time Complexity): $O(\log_{10}(x))$**
    - $x$ 是輸入的整數。
    - `while` 迴圈的執行次數等於 $x$ 的十進位位數。例如 $x=123$ 跑 3 次，$x=12345$ 跑 5 次。位數 $k$ 和 $x$ 的關係是 $k \approx \log_{10}(x)$。
4. **空間複雜度 (Space Complexity): $O(1)$**
    - 你只使用了 `negative`, `result` 等幾個固定大小的變數，需要的記憶體是固定的，與輸入 $x$ 的大小無關。

### 5. 程式碼逐行說明 (你的程式碼)

Python

```python
class Solution:
    def reverse(self, x: int) -> int:
        
        # 1. 處理符號：
        # 先記下是否為負數
        negative = x < 0
        
        # 將 x 轉為正數，簡化後續的 while 迴圈 (因為 x % 10 在負數時行為不同)
        x = -x if negative else x
        
        # 初始化反轉後的結果
        result = 0

        # 2. 數字反轉 (核心演算法)
        while x > 0:
            # "推入" (push)
            # 先將 result "向左移一位" (乘以 10)
            result *= 10
            # 再將 x "彈出" (pop) 的最後一位，加到 result 上
            result += x % 10
            
            # "彈出" (pop)
            # 移除 x 的最後一位
            x = x // 10
        
        # 3. 恢復符號
        # 如果一開始是負數，把結果轉回負數
        result = -result if negative else result

        # 4. 處理溢位 (本題陷阱)
        # 檢查最終結果是否在 32-bit 帶符號整數的範圍內
        # Python 的 2**31 就是 2 的 31 次方
        INT_MIN = -2**31
        INT_MAX = 2**31 - 1
        
        if INT_MIN <= result <= INT_MAX:
            return result
        else:
            # 如果溢位，按題目要求返回 0
            return 0
        
        # (你的一行寫法更簡潔)
        # return result if -2**31 <= result <= 2**31 - 1 else 0
```
