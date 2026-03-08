---
tags:
  - math
  - divide-and-conquer
  - recursion
---

## 題目理解

實作 `x` 的 `n` 次方，n 可以是負數。

---

## 關鍵觀察

暴力解 O(n) 會 TLE，關鍵是：

```
x^n = x^(n/2) * x^(n/2)
```

每次把問題減半，變成 O(log n)。

---

## 解題框架

用 **[[Divide and Conquer]]** / Fast Power

```
1. n == 0        → return 1
2. n < 0         → x = 1/x, n = -n
3. 遞迴減半：
   half = pow(x, n//2)
   n 是偶數 → half * half
   n 是奇數 → half * half * x
```

---

## 實作

python

```python
def myPow(self, x, n):
    if n == 0:
        return 1
    
    if n < 0:
        x = 1 / x
        n = -n
    
    def recursion(x, n):
        if n == 1:
            return x
        
        half = recursion(x, n // 2)
        
        if n % 2 == 0:
            return half * half
        else:
            return half * half * x
    
    return recursion(x, n)
```

---

## 複雜度

| | |
|---|---|
| Time | O(log n)，每次 n 減半 |
| Space | O(log n)，遞迴深度 |

---

## 我卡在哪 / 要注意的地方

**奇偶數的差異：**
```
n=4（偶）: x^4 = x^2 * x^2
n=5（奇）: x^5 = x^2 * x^2 * x  ← 多乘一個 x
````

**n < 0 的處理要在進遞迴之前：**

先把 `x = 1/x`，`n = -n`，之後遞迴只需要處理正數，邏輯乾淨。

**recursion base case 是 `n == 1` 不是 `n == 0`：**

因為外層已經處理了 `n == 0`，遞迴進來的 n 一定 ≥ 1。

---

## Flashcards

Fast Power 核心公式 :: `x^n = x^(n//2) * x^(n//2)`，n 為奇數時再多乘一個 x

n 為負數時怎麼處理 :: 進遞迴前先 `x = 1/x, n = -n`，之後只處理正數

Fast Power 的時間複雜度為什麼是 O(log n) :: 每次 n 除以 2，總共只需要 log n 層遞迴

---

## 相關題目

- [[LC-372-Super-Pow]] ← 同樣 Fast Power，加上 mod 運算