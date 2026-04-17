---
notion-id: 2bb5a6e2-1812-8014-a8f0-d9c7ba198949
---
**難度：⭐ Medium**

**面試常考度：⭐⭐⭐⭐（非常常考）**

**主題：DP、字串、切割、字典查詢**

---

# **📘 題意**

給一個字串 `s` 和一個字典 `wordDict`，判斷 `s` 是否可以被切割成字典內的單字組合。

例子：

```plain text
s = "leetcode"
wordDict = ["leet", "code"]
→ Tru
```

---

# **💡 思路（DP 動態規劃）**

建立一個 DP 陣列表示：

```plain text
dp[i] = s[0:i] 能不能被切成合法單字
```

初始化：

```plain text
dp[0] = True   # 空字串永遠合法
```

接著逐位檢查 `s`，對每一個索引 `i`，從字典可能的單字長度範圍內嘗試切割：

- 字典內最短字長：`minLength`
- 字典內最長字長：`maxLength`
- 避免不必要的 substring 檢查 → 效能大幅提升

對每個可能的字長 `l`：

```plain text
j = i - l
若 dp[j] 為 True，且 s[j:i] 存在於 dictSet → dp[i] = True
```

最後回傳 `dp[len(s)]`。

---

# **🧾 完整程式碼（含最佳化：只檢查合理字長）**

```python
class Solution:
    def wordBreak(self, s: str, wordDict: List[str]) -> bool:
        dp = [False] * (len(s) + 1)
        dictSet = set(wordDict)
        dp[0] = True

        minLength = min(len(w) for w in wordDict)
        maxLength = max(len(w) for w in wordDict)

        for i in range(1, len(s)+1):
            for l in range(minLength, maxLength+1):
                j = i - l

                if j < 0:
                    continue

                if dp[j] and s[j:i] in dictSet:
                    dp[i] = True
                    break

        return dp[len(s)]


```

---

# **🧠 為什麼這樣更快？**

原本暴力寫法是：

```plain text
對每個 i，檢查所有 j from 0 to i
→ O(n^2)


```

但實際只有「字典內字的長度」會影響結果。

例如：

```plain text
wordDict = ["leet", "code"]
→ 字長範圍 = 4~4


```

不需要檢查長度 1、2、3、5… 的 substring。

這個優化在字典很大時非常有效。

---

# **⏱ 時間複雜度 & 空間複雜度**

| 項目 | 複雜度 |
| --- | --- |
| 時間 | **O(n × L)**，L = 字典最大字長 - 最小字長 |
| 空間 | **O(n)**（DP 陣列） |

比原本 O(n²) 明顯更快。

---

# **📌 邊界條件**

- `s` 很短 → 還是能 AC
- `wordDict` 只有一個單字 → min/max 相等
- 字典裡有很長的字 → 只要 substring 長度不符就跳過
- `wordDict` 裡有重複字 → set 自動去重

---

# **🔥 面試技巧**

- 面試官常問：
**「為什麼不用暴力全部檢查？」**
→ 記得回答：「我們只需要檢查字典中可能出現的字長範圍，減少不必要 substring 檢查。」
- 常常會 follow-up：
**「可以用 BFS 或 Trie 解嗎？」**
→ BFS 也能做，但 DP 是最穩定的寫法。