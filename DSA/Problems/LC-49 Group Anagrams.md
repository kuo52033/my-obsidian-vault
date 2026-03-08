---
tags:
  - hashmap
  - string
  - sorting
---

## 題目理解

給一個字串陣列，把所有 anagram（字母組成相同）的字串分在同一組。

---

## 關鍵觀察

Anagram 的特性：**排序後的結果一定相同**。

```
"eat" → "aet"
"tea" → "aet"
"tan" → "ant"
"ate" → "aet"
```

所以用排序後的字串當 key，就能把同組的 anagram 自動歸類。

---

## 解題框架

用 **[[HashMap]]

```
for 每個字串 s:
    key = sorted(s) 排序後join
    hashmap[key].append(s)

return hashmap.values()
```

---

## 實作

python

```python
def groupAnagrams(self, strs):
    hash_map = collections.defaultdict(list)

    for s in strs:
        key = "".join(sorted(s))
        hash_map[key].append(s)
    
    return list(hash_map.values())
```

---

## 複雜度

|       |              |
| ----- | ------------ |
| Time  | O(n * klogk) |
| Space | O(n*k)       |

n 是字串數，k 是最長字串長度

---

## 進階：不用 sort 的 O(n · k) 解法

用 **26個字母的計數** 當 key，避免排序：

python

````python
def groupAnagrams(self, strs):
    hash_map = collections.defaultdict(list)

    for s in strs:
        count = [0] * 26
        for c in s:
            count[ord(c) - ord('a')] += 1
        hash_map[tuple(count)].append(s)
    
    return list(hash_map.values())
```
```
"eat" → (1,0,0,0,1,0,...,1,0,0)  ← a=1, e=1, t=1
"tea" → (1,0,0,0,1,0,...,1,0,0)  ← 相同！
````

---

## 我卡在哪 / 要注意的地方

- `defaultdict(list)` 的好處：key 不存在時自動初始化為空 list，不需要手動 `if key not in hash_map`
- sort 後要 `"".join()` 才能當 hashmap 的 key，list 本身不能 hash
- 進階解法用 `tuple(count)` 當 key，因為 list 同樣不能 hash

---

## Flashcards

Group Anagrams 用什麼當 hashmap 的 key :: 排序後的字串 `"".join(sorted(s))`，anagram 排序後一定相同

為什麼不能直接用 `sorted(s)` 當 key :: sorted 回傳 list，list 不可 hash，需要先 join 成字串或轉成 tuple

不用 sort 的進階解法 key 是什麼 :: 26個字母的計數 `tuple([0]*26)`，Time 從 O(k log k) 降到 O(k)

---

## 相關題目

- [[LC-242-Valid-Anagram]] ← 判斷兩個字串是否為 anagram，基礎版
- [[LC-438-Find-All-Anagrams-in-a-String]] ← sliding window + 計數找所有 anagram 位置