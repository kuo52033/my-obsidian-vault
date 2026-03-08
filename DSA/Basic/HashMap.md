- [[LC-49 Group Anagrams]]


用 **key-value** 儲存資料的資料結構，透過 hash function 把 key 轉成陣列的 index，達到 O(1) 的存取速度。
```
key → hash function → index → value 
"eat" → hash() → 42 → "found"
```

### Time complexity

| op     | average | worst case |
| ------ | ------- | ---------- |
| Insert | O(1)    | O(n)       |
| Lookup | O(1)    | O(n)       |
| Delete | O(1)    | O(n)       |
Worst case 發生在 **hash collision**（多個 key 被分配到同一個 index）。

---

### Python 用法
```python
	# 基本 dict
	seen = {}
	seen["key"] = 1
	if "key" in seen:
	    print(seen["key"])
	
	# defaultdict - key 不存在時自動初始化
	from collections import defaultdict
	hash_map = defaultdict(list)   # 預設值是 []
	hash_map = defaultdict(int)    # 預設值是 0
	hash_map = defaultdict(set)    # 預設值是 set()
	
	# Counter - 直接計數
	from collections import Counter
	count = Counter("eating")  # {'e':1, 'a':1, 't':1, 'i':1, 'n':1, 'g':1}
	count["e"]  # 1
```

---

### Space Complexity

塞多少資料進去，就佔多少空間。
```python
# O(n) - 存 n 個數字
seen = {}
for num in nums:
    seen[num] = True

# O(n · k) - 存 n 個長度為 k 的字串
hash_map = defaultdict(list)
for s in strs:
    key = "".join(sorted(s))   # key 長度 k
    hash_map[key].append(s)    # value 也是長度 k 的字串
```

---
## 什麼時候用 HashMap

- 需要 **O(1) 查找**某個值是否存在
- 需要**計數**或**統計頻率**
- 需要**分組**相同性質的資料
- 需要**記憶化**遞迴結果
---
### Hash Collision
