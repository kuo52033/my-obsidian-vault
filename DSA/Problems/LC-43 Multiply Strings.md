---
tags:
  - math
  - string
---


---

## 題目理解

給兩個用字串表示的非負整數，回傳相乘結果（也用字串表示），不能直接用內建的大數乘法。

---

## 關鍵觀察

模擬手算乘法，每一位相乘的結果會落在固定的位置：

```
num1[j] × num2[i] 的結果
個位數 → result[i+j+1]
十位數 → result[i+j]
```

最多 m+n 位，所以 result 開 m+n 長度。

---

## 手算對照

```
    1 2 3   (num1, m=3)
  ×   4 5   (num2, n=2)
---------
i=1,j=2: 5×3=15 → result[4]+=5, result[3]+=1
i=1,j=1: 5×2=10 → result[3]+=0, result[2]+=1
i=1,j=0: 5×1=5  → result[2]+=5, result[1]+=0
i=0,j=2: 4×3=12 → result[3]+=2, result[2]+=1
i=0,j=1: 4×2=8  → result[2]+=8, result[1]+=0
i=0,j=0: 4×1=4  → result[1]+=4, result[0]+=0
```

---

## 解題框架

```
1. result 陣列開 m+n 位，全部初始化為 0
2. 從右往左逐位相乘
3. 個位數放 result[i+j+1]，進位放 result[i+j]
4. 最後 join 並去掉前導 0
```

---

## 實作

python

```python
def multiply(self, num1, num2):
    if num1 == '0' or num2 == '0':
        return '0'

    m, n = len(num1), len(num2)
    result = [0] * (m + n)

    for i in range(n - 1, -1, -1):
        for j in range(m - 1, -1, -1):
            mul = int(num2[i]) * int(num1[j])

            mul += result[i+j+1]      # 先加上這格已有的值

            result[i+j+1] = mul % 10  # 個位數直接賦值
            result[i+j] += mul // 10  # 進位用加的

    return "".join(map(str, result)).lstrip("0")
```

---

## 複雜度

|       |          |
| ----- | -------- |
| Time  | O(m × n) |
| Space | O(m + n  |

---

## 我卡在哪 / 要注意的地方

**為什麼 `result[i+j+1]` 直接賦值，`result[i+j]` 用加的：**

`result[i+j+1]` 是個位數的格子，**每次計算前先把這格已有的值加進來一起處理**：

python

```python
mul += result[i+j+1]   # 把這格已有的值合併進 mul
result[i+j+1] = mul % 10  # 重新算出這格應該放什麼 → 直接覆蓋
```

這格的最終值已經在這次計算中確定了，所以**直接賦值**。

`result[i+j]` 是進位的格子，**這格之後還會被其他乘法結果再加進來**：
```
i=1,j=2: result[3] += 1   （5×3 的進位）
i=1,j=1: result[3] += 0   （5×2 的個位）
i=0,j=2: result[3] += 2   （4×3 的個位）
```

同一格會被多次累加，所以**用加的，不能覆蓋**。

**一句話：個位格在這次算完就定了，用賦值；進位格之後還有人會加進來，用累加。**

---

## 視覺化 result 陣列
```
    1 2 3
  ×   4 5
result = [_, _, _, _, _, _]
index =   0  1  2  3  4  5

num1[j] × num2[i] 落點：
j=2,i=1(5×3) → index 4(個位), index 3(進位)
j=1,i=1(5×2) → index 3(個位), index 2(進位)
j=0,i=1(5×1) → index 2(個位), index 1(進位)
j=2,i=0(4×3) → index 3(個位), index 2(進位)
j=1,i=0(4×2) → index 2(個位), index 1(進位)
j=0,i=0(4×1) → index 1(個位), index 0(進位)
````

---

## Flashcards

`num1[j] × num2[i]` 的個位和進位分別落在哪個 index :: 個位 → `result[i+j+1]`，進位 → `result[i+j]`

為什麼個位格用賦值，進位格用累加 :: 個位格每次計算前已合併舊值，結果直接覆蓋；進位格之後還會被其他乘法累加，不能覆蓋

---

## 相關題目

- [[LC-415-Add-Strings]] ← 同樣字串模擬，加法版本
- [[LC-66-Plus-One]] ← 陣列模擬進位