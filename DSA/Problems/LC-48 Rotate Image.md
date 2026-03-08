---
tags:
  - matrix
  - math
---

## 題目理解

給一個 n × n 矩陣，順時針旋轉 90 度，**in-place** 不能用額外空間。

---

## 關鍵觀察

直接旋轉很難想，但有一個數學技巧：

```
順時針旋轉 90° = 先 Transpose + 再 Reverse 每一行
```

具體例子：

```
原始：          Transpose：      Reverse 每行：
1 2 3          1 4 7            7 4 1
4 5 6    →     2 5 8      →     8 5 2
7 8 9          3 6 9            9 6 3
```

---

## 為什麼是這個順序

**Transpose**：把 `matrix[i][j]` 和 `matrix[j][i]` 互換，沿對角線翻轉。

**Reverse**：把每一行左右對調。

兩步合起來剛好等於順時針 90°，順序不能反：

```
如果先 Reverse 再 Transpose → 變成逆時針 90°
```

---

## 解題框架

```
Step 1: Transpose
  → 只需要走上三角（j 從 i 開始），避免換兩次回原位

Step 2: Reverse 每一行
  → 每行只需要走一半（j 走到 n//2），左右對調
```

---

## 實作

python

```python
def rotate(self, matrix):
    n = len(matrix)

    # Step 1: Transpose
    for i in range(n):
        for j in range(i, n):  # j 從 i 開始，只走上三角
            matrix[i][j], matrix[j][i] = matrix[j][i], matrix[i][j]

    # Step 2: Reverse 每一行
    for i in range(n):
        for j in range(n // 2):  # 只走一半
            matrix[i][j], matrix[i][n-j-1] = matrix[i][n-j-1], matrix[i][j]
```

---

## 複雜度

| | |
|---|---|
| Time | O(n²)，每個元素碰一次 |
| Space | O(1)，in-place |

---

## 我卡在哪 / 要注意的地方

**最難的地方是想到「Transpose + Reverse」這個拆解：**

直接旋轉要追蹤四個角同時換，很容易搞混：
```
直接旋轉：(i,j) → (j, n-i-1) → (n-i-1, n-j-1) → (n-j-1, i) → 回到 (i,j)
四個位置同時換，index 很容易算錯
```

Transpose + Reverse 把問題拆成兩個簡單步驟，每步只換兩個位置。

**Transpose 為什麼 j 從 i 開始：**
```
如果 j 從 0 開始，(i=0,j=1) 換完，之後 (i=1,j=0) 又換回來
→ 等於沒換
從 j=i 開始只走上三角，每對只換一次
```

**Reverse 為什麼只走 n//2：**
```
左右對調，走到一半就好
走超過一半會把已經換好的再換回來
````

---

## Flashcards

順時針旋轉 90° 的兩步驟 :: 先 Transpose（沿對角線翻轉） + 再 Reverse 每一行

Transpose 時為什麼 j 從 i 開始而不是 0 :: 避免同一對換兩次回原位，只走上三角每對剛好換一次

逆時針旋轉 90° 怎麼做 :: 先 Reverse 每一行 + 再 Transpose，順序反過來

---

## 相關題目

- [[LC-54-Spiral-Matrix]] ← 同樣是矩陣操作，邊界模擬
- [[LC-73-Set-Matrix-Zeroes]] ← in-place 矩陣修改