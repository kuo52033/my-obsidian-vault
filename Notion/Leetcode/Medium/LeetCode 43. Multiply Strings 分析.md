---
notion-id: 29b5a6e2-1812-806e-9be2-df23acc6f26c
---
### 1. 難度 (最高五星)

- **難度：** ★★★☆☆ (3/5)
- **說明：** 這是一道 "Medium" 難度的題目。它不考察高深的演算法 (如 DP、回溯)，而是紮實地考察你「**模擬**」基本運算的能力，以及對「**進位**」和「**陣列索引**」的細節處理。

### 2. 運用到的技巧

1. **陣列模擬乘法 (Array Simulation):**
    - 這是這題的最佳解法。你沒有試圖去「字串相加」，而是利用一個 `result = [0] * (n+m)` 的整數陣列來儲存「直式乘法」在*每一個位數*上的中間結果。
2. **索引定位 (Index Mapping):**
    - 🧠 這是演算法最核心的「大腦」。你精確地找到了 `num1[j]` 和 `num2[i]` 相乘的結果 `product`，應該被分配到 `result` 陣列的哪兩個位置：
    - **十位數 (進位)：** `result[i + j]`
    - **個位數：** `result[i + j + 1]`
3. **手動進位 (Manual Carry & Accumulation):**
    - `sum_one = result[i+j+1] + product`
    - `result[i+j] += sum_one // 10`
    - `result[i+j+1] = sum_one % 10`
    - 這三行完美地處理了乘法後的「進位」。`**+=**` (累加) 是關鍵，因為 `result[i+j]` (十位數) 這個位置，可能會被好幾輪的乘法 (例如 `3*5` 的進位 `1` 和 `2*4` 的進位 `0`) 同時累加。
4. **Pythonic 輸出處理 (你的新寫法):**
    - `str_list = map(str, result)`：高效地將 `[0, 5, 5, 3, 5]` 轉為 `['0', '5', '5', '3', '5']`。
    - `final_str = "".join(str_list)`：高效地合併為 `"05535"`。
    - `return final_str.lstrip("0")`：**神來一筆**。利用 `lstrip("0")` 函式，一次性刪除*所有*左邊的前導 0。
    - `**"0"**`** 邊界處理：** 你的 `if num1[0] == "0" ...` 確保了 `lstrip` 永遠不會把 `[0, 0, 0]` 這種結果變成 `""` (空字串)，因為那種情況在第一行就 `return "0"` 了，這讓你的 `lstrip` 100% 安全。

### 3. 時間與空間複雜度

- $M$ = `num1` 的長度
- $N$ = `num2` 的長度
5. **時間複雜度 (Time Complexity): $O(M \times N)$**
    - 你的程式碼有兩個巢狀 `for` 迴圈，分別遍歷 `N` (m-1 to -1) 和 `M` (n-1 to -1)。
    - 迴圈內部的操作 (乘法、加法、取餘、索引) 都是 $O(1)$。
    - 因此，總時間複雜度是 $O(M \times N)$。
6. **空間複雜度 (Space Complexity): $O(M + N)$**
    - 你需要一個額外的 `result` 陣列，其長度為 `n + m` (即 $M + N$)。
    - 因此，空間複雜度是 $O(M + N)$。

---

### 程式碼逐行說明 (你的程式碼)

Python

```python
class Solution:
    def multiply(self, num1: str, num2: str) -> str:
        
        # 1. 處理 "0" 的邊界情況，這也讓
        #    最後的 .lstrip("0") 變得安全
        if num1[0] == "0" or num2[0] =="0":
            return "0"

        n = len(num1)
        m = len(num2)
        
        # 2. 建立 M+N 長度的 "結果" 陣列
        result = [0 for _ in range(n+m)]

        # 3. 遍歷 num2 (乘數)，從右到左
        for i in range(m-1, -1, -1):
            # 4. 遍歷 num1 (被乘數)，從右到左
            for j in range(n-1, -1, -1):
                
                # 5. 取得兩位數的乘積
                #    (int() 在這裡是安全的，因為 j 和 i 都是單一字元)
                product = int(num1[j]) * int(num2[i])

                # 6. 核心進位邏輯：
                #    p_ones = i+j+1 (個位數的索引)
                #    p_tens = i+j   (十位數的索引)
                
                #    先將 "乘積" 和 "個位數" 位置上 "已有的值" 相加
                sum_one = result[i+j+1] + product

                #    "個位數" 位置只保留 sum_one 的 "餘數"
                result[i+j+1] = sum_one % 10
                #    "十位數" 位置 "累加" sum_one 的 "商" (進位)
                result[i+j] += sum_one // 10

        # 7. Pythonic 的合併
        #    [0, 5, 5, 3, 5] -> map(str) -> ["0", "5", "5", "3", "5"]
        str_list = map(str, result)
        #    -> "".join -> "05535"
        final_str = "".join(str_list)
        
        # 8. 移除所有左側的前導 0
        #    "05535" -> "5535"
        #    "00123" -> "123"
        return final_str.lstrip("0")
```