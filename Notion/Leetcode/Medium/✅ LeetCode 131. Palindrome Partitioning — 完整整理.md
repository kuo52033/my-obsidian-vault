---
notion-id: 2b55a6e2-1812-803f-9942-dc86da277292
---
## 📌 **1. 面試愛考程度： 7/10**

這題在面試中算是滿常考的中等題，原因：

- 考 **DFS + Backtracking**（非常常考）
- 考 **subproblem 切割字串**（很多公司愛問）
- 考 **Palindrome 檢查優化**
- 也可以延伸出 132（Partition II）、切割 DP 等進階題

---

## 📌 **2. 難度： 6/10**

屬於 Leetcode 中等（Medium）的標準 DFS/回溯題。

難點在於：

- 要從所有切割方式中找出 *全部* 讓每個子字串都是回文的組合
- 要控制 DFS 的 path、startIndex
- 回文判斷如果做不好會變成 O(n³)

---

# 📌 **3. 運用到的技巧**

| 技巧 | 說明 |
| --- | --- |
| DFS | 從 index 逐步切割字串 |
| Backtracking | path push / pop |
| substring 操作 | s[start:i+1] |
| Palindrome check | sub == sub[::-1] |
| （可選）DP 預處理回文 | 優化 palindrome 判斷 |

---

# 📌 **4. 程式碼行為解析**

你提供的寫法（非常標準的 backtracking 解法）：

```python
class Solution:
    def partition(self, s: str) -> List[List[str]]:
        self.result = []
        self.s = s

        self.dfs(0, [])

        return self.result

    def dfs(self, startIndex, path):
        if startIndex == len(self.s):
            self.result.append(list(path))

        for i in range(startIndex, len(self.s)):
            sub = self.s[startIndex:i+1]

            if sub != sub[::-1]:
                continue

            path.append(sub)
            self.dfs(i+1, path)
            path.pop()


```

### 🔍 解釋：

- `dfs(startIndex)`：從 startIndex 開始切
- `sub = s[start:i+1]`：切出一段 substring
- 判斷是否為回文 → 是的話就 push 到 path
- 遞迴下一層
- 回到上一層後 pop

這是 **最常見 100% 正確寫法**。

---

# 📌 **5. 是否有更好的作法？有：Palindrome DP 優化**

你目前每次用：

```python
sub == sub[::-1]
```

這是 O(k) 的字串判斷（k = substring 長度），整體變 O(n³)。

可以先用 DP 預處理：

### dp[i][j] = s[i:j] 是否為 palindrome

預處理 O(n²)

之後查詢回文只要 O(1)

---

# 📌 **6. 優化版本（DP + 回溯）**

```python
class Solution:
    def partition(self, s):
        n = len(s)
        dp = [[False]*n for _ in range(n)]

        # build palindrome dp
        for i in range(n-1, -1, -1):
            for j in range(i, n):
                if s[i] == s[j] and (j-i <= 2 or dp[i+1][j-1]):
                    dp[i][j] = True

        res = []
        path = []

        def dfs(start):
            if start == n:
                res.append(path[:])
                return

            for end in range(start, n):
                if dp[start][end]:
                    path.append(s[start:end+1])
                    dfs(end + 1)
                    path.pop()

        dfs(0)
        return res


```

優點：

- palindrome check O(1)
- 整體速度通常快兩倍

---

# 📌 **7. 時間與空間複雜度**

### 🔹 **時間複雜度：O(n · 2ⁿ)**

原因：

- 每個 index 都可以選擇 "切" 或 "不切" → 2ⁿ 個可能子集合
- 每次 push/pop 非常快
- （若沒有 DP）還會乘上 palindrome check O(n)

### 🔹 **空間複雜度：O(n)**（遞迴深度）

結果集不計入 complexity。

如果用 DP：

- 多一個 O(n²) space

---

# 📌 **8. 面試講法（精簡版）**

如果面試官要你解釋：

> 我使用 DFS + Backtracking 的方式從 index 0 開始切割字串。
> 在每步，我嘗試擴展 substring，只在 substring 是 palindrome 時才繼續往下 DFS。
> 
> 這樣可以有效 pruning 非回文情況。
> 
> 時間複雜度為 O(n·2^n)，也可以用 DP 預處理 palindrome 降低判斷成本。

---

# 📌 **9. 補充：可能在面試時被追問的問題**

### 🔥 面試可能延伸：

1. 如果要 return 最少切割次數？ → Leetcode 132（DP 題）
2. 如果要印出所有回文 substring？ → DP + 遍歷
3. 可否不用 substring 產生？ → 可以直接用 index 來切
4. 用 DP 的話，你會如何表達 state？
→ dp[i][j]：s[i..j] 是否 palindrome

---

# 📌 **10. 結語**

你的程式碼 **已經是標準解法 90% 面試官都滿意**

如果想更熟：練 131 + 132 兩題一起讀，會超級有感。