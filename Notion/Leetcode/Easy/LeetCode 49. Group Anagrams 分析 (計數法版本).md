---
notion-id: 2a05a6e2-1812-80df-8619-d6153b991e7a
---
### 1. 難度 (最高五星)

- **難度：** ★★☆☆☆ (2/5)
- 說明： 這是一道 "Medium" 難度的題目。它的核心是「雜湊 (Hashing)」。這題的難點在於，你必須自己設計一個「Key」，讓所有「異位詞 (Anagrams)」都能被
Hash 到同一個 Key 上。

### 2. 運用到的技巧

1. **雜湊表 (Hash Map):**
    - `hash_map = collections.defaultdict(list)`
    - 你使用了 `defaultdict(list)`，這非常 Pythonic！它省去了 `if key not in hash_map:` 的檢查，讓程式碼更簡潔。
2. **計數法 (Counting / Array as a Map):**
    - `count = [0] * 26`
    - 這是你這個解法的**核心**。你沒有用 $O(K \log K)$ 的排序，而是用 $O(K)$ 的「計數」來產生 Key。
    - **原理：** 所有的異位詞 (如 "eat", "tea")，它們的「字元計數」一定是*完全相同*的。
    - `ord(ss) - ord('a')` 是一個經典技巧，用來把 `a-z` 的字元完美地對應到 `0-25` 的陣列索引。
3. **元組 (Tuple) as Key:**
    - `hash_map[tuple(count)].append(s)`
    - 這是另一個關鍵點。在 Python 中，`list` (列表) 是「可變的 (mutable)」，不能作為字典的 Key。
    - `tuple` (元組) 是「不可變的 (immutable)」，可以作為 Key。
    - 你使用 `tuple(count)` 把 `list` 轉成 `tuple`，非常正確！

### 3. 核心邏輯分析 (排序法 v.s. 計數法)

- **方法一 (排序法，你上一題的)：**
    - `key = "".join(sorted(s))`
    - 產生 Key 的成本：**$O(K \log K)$** ( $K$ 是字串長度)
- **方法二 (計數法，你這題的)：**
    - `count = [0] * 26` 搭配 `for ss in s:`
    - 產生 Key 的成本：**$O(K)$** ( $K$ 是字串長度)

**結論：** 你的「計數法」在*理論上*是更快的，它把 $K \log K$ 的瓶頸優化成了 $O(K)$。

### 4. 時間與空間複雜度

- $N$ = `strs` 列表中的**字串數量**。
- $K$ = 列表中**字串的最大長度**。
4. **時間複雜度 (Time Complexity): $O(N \times K)$**
    - **分析：**
        - 你的外層迴圈 `for s in strs:` 跑了 $N$ 次。
        - 內層迴圈 `for ss in s:` (產生 `count` 陣列) 跑了 $K$ 次。
        - `tuple(count)` 和 `hash_map.append()` 都是 $O(1)$ 或 $O(K)$ ( $K$ 在此處為 26，可視為常數 $O(1)$ )。
        - **總時間 = $O(N \times K)$**。
    - 這比「排序法」的 $O(N \times K \log K)$ 要快。
5. **空間複雜度 (Space Complexity): $O(N \times K)$**
    - **分析：**
        - `hash_map` 需要儲存*所有*的字串。
        - 在最壞情況下 (所有字串都不是異位詞)，`hash_map` 會有 $N$ 個 Key。
        - 儲存 `hash_map` 的 Key ( $N$ 個長度為 26 的 `tuple` ) $\to O(N \times 26) \to O(N)$。
        - 儲存 `hash_map` 的 Value ( $N$ 個字串，平均長度 $K$ ) $\to O(N \times K)$。
        - **總空間 = $O(N \times K)$** (由儲存的字串本身主導)。

---

### 程式碼逐行說明 (你的程式碼)

Python

```python
import collections

class Solution:
    def groupAnagrams(self, strs: List[str]) -> List[List[str]]:
        
        # 1. 建立一個 defaultdict。
        #    當 key 不存在時，會自動建立一個 "list()"
        hash_map = collections.defaultdict(list)

        # 2. 遍歷 N 個字串 (s)
        for s in strs:
            
            # 3. 建立一個長度 26 的計數器 (代表 a-z)
            count = [0] * 26
            
            # 4. 遍歷 s 中的 K 個字元 (ss)
            for ss in s:
                # 5. [O(K) 核心]
                #    用 ord() 取得 ASCII 碼，
                #    相減來對應到 0-25 的索引
                count[ord(ss) - ord('a')] += 1
            
            # 6. [O(1) 核心]
            #    Python 的 list 不能當 key，
            #    所以把 count 轉成 "tuple" (元組)
            #    e.g., (1, 0, 0, 0, 1, ..., 1, ...)
            key = tuple(count)
            
            # 7. 將原字串 s 加入對應 key 的 list
            hash_map[key].append(s)
        
        # 8. 返回 hash_map 中所有的 "值" (也就是那些 list)
        return list(hash_map.values())
```