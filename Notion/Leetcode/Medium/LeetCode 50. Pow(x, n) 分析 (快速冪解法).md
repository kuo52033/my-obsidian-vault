---
notion-id: 2a45a6e2-1812-8019-bd4c-f4f6dba5c02c
---
### 1. 難度 (最高五星)

- **難度：** ★★☆☆☆ (2/5)
- **說明：** 這是一道 "Medium" 難度的題目。它考察的是一個非常經典的演算法：「**二元指數法 (Exponentiation by Squaring)**」或「**快速冪**」。這題的難點在於，你必須跳出 $O(N)$ ( $x \times x \times \dots$ ) 的直觀思維，想到 $O(\log N)$ 的「分治 (Divide and Conquer)」解法。

---

### 2. 運用到的技巧

1. **分治法 (Divide and Conquer):**
    - 這是你 `fast` 函式的核心。你把計算 $x^n$ 的大問題，**分解**成計算 $x^{n/2}$ ( `half` ) 的小問題。
    - 然後你再把小問題的答案 (`half`) **組合**起來 (`half * half`) 得到大問題的答案。
2. **遞迴 (Recursion):**
    - 你是透過遞迴來實現這個分治演算法的。

---

### 3. 核心邏輯分析 (你的程式碼)

你的程式碼分為兩個漂亮的部分：

**A. **`**myPow**`** 函式 (前置處理):**

Python

```python
def myPow(self, x: float, n: int, temp = 1) -> float:    
    # 1. 處理負數 n：
    #    你只在 "最外層" 處理一次，這很棒。
    if n < 0:
        n *= -1
        x = 1/x
    
    # 2. 呼叫 "輔助函式" 去跑 O(log N) 的演算法
    return self.fast(x, n)
```

**B. **`**fast**`** 函式 (核心演算法):**

Python

```python
def fast(self, x, n):
    # 1. 基礎情況 (Base Case):
    #    遞迴的終點。 x^0 永遠是 1。
    if n == 0:
        return 1

    # 2. 分治 (Divide):
    #    無論 n 是奇數還是偶數，我們都先計算 x^(n//2)
    #    (注意：這一步遞迴呼叫 "只做一次"，所以很高效)
    half = self.fast(x, n//2)
    
    # 3. 組合 (Combine):
    
    #    情況一：n 是偶數 (e.g., n=10)
    #    x^10 = (x^5) * (x^5) = half * half
    if n % 2 == 0:
        return half * half
    
    #    情況二：n 是奇數 (e.g., n=11)
    #    x^11 = (x^5) * (x^5) * x = half * half * x
    else:
        return half * half * x
```

- `**half = self.fast(x, n//2)**` 這一行是關鍵。你把 $x^{n/2}$ 的結果存起來，這樣你只需要計算 `half * half`，而不是 `self.fast(x, n//2) * self.fast(x, n//2)` (如果是後者，會導致重複計算，退化成 $O(N)$ )。你的寫法是最高效的。

---

### 4. 時間與空間複雜度

- $n$ = 指數的大小。
3. **時間複雜度 (Time Complexity): $O(\log N)$**
    - **分析：** 你的遞迴 `self.fast(x, n//2)` 在每一步都把問題規模 `n` 砍了一半。
    - `n` $\to$ `n/2` $\to$ `n/4` $\to$ ... $\to$ `1` $\to$ `0`
    - 這個過程需要 $\log_2(n)$ 步。每一步都只做一次乘法，所以總時間是 $O(\log N)$。
4. **空間複雜度 (Space Complexity): $O(\log N)$**
    - **分析：** 空間成本來自「**函式呼叫堆疊 (Call Stack)**」。
    - 因為遞迴的深度是 $\log_2(n)$，所以呼叫堆疊最多會佔用 $O(\log N)$ 的空間。
    - (P.S. 這題也可以用「迭代 (Iterative)」解，空間複雜度可以優化到 $O(1)$，但 $O(\log N)$ 的遞迴解法通常已經是面試官滿意的答案了。)