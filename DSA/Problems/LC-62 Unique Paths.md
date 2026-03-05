---
tags:
  - dp
  - grid
difficulty: Medium
---
## 題目理解

一個 `m x n` 的 grid，從左上角走到右下角，每次只能往右或往下，問有幾條不同路徑。

---

## 關鍵觀察

- 第一行和第一列永遠只有 **1 種走法**（只能一直往右 or 一直往下）
- 其他格子的走法數 = 從上面來 + 從左邊來
- 不需要考慮走回頭路，所以沒有重複子問題的疑慮

---
## 解題框架

用 **[[2D DP]]**

```python
dp[i][j] = 到達 (i, j) 的路徑數
dp[i][j] = dp[i-1][j] + dp[i][j-1]
```

Base case：

```python
dp[i][0] = 1  # 第一列
dp[0][j] = 1  # 第一行
```

---
## 實作

python

```python
def uniquePaths(self, m: int, n: int) -> int:
    dp = [[0] * n for _ in range(m)]

    for i in range(m):
        dp[i][0] = 1
    
    for j in range(n):
        dp[0][j] = 1

    for i in range(1, m):
        for j in range(1, n):
            dp[i][j] = dp[i-1][j] + dp[i][j-1]

    return dp[m-1][n-1]
```

---
## [[time and space complexity]]

- Time: O(m x n)，每格走一次
- Space: O(m x n)，可優化成 O(n)

**Space 優化思路**（進階）： 每次只需要「上一行」的資料，可以只維護一個 1D array 滾動更新。

```python
class Solution:

    def uniquePaths(self, m: int, n: int) -> int:
        dp = [1]*n

        for i in range(1, m):
            for j in range(1, n):
                dp[j] = dp[j] + dp[j-1]

        return dp[n-1]
```

--- 
### 我卡在哪 / 要注意的地方

Space complexity 如何優化成 O (n) ?