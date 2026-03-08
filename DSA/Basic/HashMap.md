- [[LC-49 Group Anagrams]]


用 **key-value** 儲存資料的資料結構，透過 hash function 把 key 轉成陣列的 index，實作的是 **associative array** 這個抽象資料型別
```
key → hash function → index → value 
"eat" → hash() → 42 → "found"
```

> [!NOTE]  **associative array**
> **Abstract Data Type (ADT)** 是一個概念，只定義「能做什麼操作」，不管底層怎麼實作。
> Associative Array 這個 ADT 定義很簡單：
> - `set(key, value)` － 存一個值
> - `get(key)` → value － 用 key 取值
>   `delete(key)` － 刪除

### Time complexity

| op     | average | worst case |
| ------ | ------- | ---------- |
| Insert | O(1)    | O(n)       |
| Lookup | O(1)    | O(n)       |
| Delete | O(1)    | O(n)       |
Worst case 發生在 **hash collision**（多個 key 被分配到同一個 index）。

- 線性搜尋：不用額外空間，但每次查找 O(n)
- HashMap：先花 O(n) space 把資料都 hash 進去，之後每次查找 O(1)

==**用空間換時間**==

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

Hash function 把 key 轉成 index，但陣列大小有限，有時候**兩個不同的 key 會被分配到同一個 index**，這就是 collision。
```
"eat"  → hash() → index 3
"listen" → hash() → index 3  ← collision！
```

解決方法
**方法一 Chaining（串鏈）**
同一個 index 用 linked list 把所有衝突的 key 串起來：

```
index 3 → ["eat" → "listen" → null]
index 5 → ["hello" → null]
```

查找時先找到 index，再走 linked list 找正確的 key。 最壞情況所有 key 都塞在同一個 index → ==退化成 O(n)==。

**方法二 Open Addressing（開放定址）**
碰到 collision 就往後找下一個空位：

```
想放 index 3，但 3 已經有人了
→ 試 index 4，空的 → 放這裡
```

查找時也是從原本的 index 開始，往後找直到找到或空位為止。

**Python 的 dict 用這個方法。**
