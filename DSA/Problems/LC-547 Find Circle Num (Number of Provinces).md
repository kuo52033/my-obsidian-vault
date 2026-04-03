
## 題目理解

給一個 n×n 的 adjacency matrix，`isConnected[i][j] == 1` 代表城市 i 和 j 直接相連，找出有幾個互相連通的省份（connected components）。

---

## 關鍵觀察

每個 connected component 就是一個省份，用 Union Find 把相連的城市合併，最後數有幾個不同的 root。

---

## 解題框架

用 **[[Union Find Pattern]]**

```
初始化：每個城市是自己的 root
遍歷 matrix：
  isConnected[i][j] == 1 且 i != j → union(i, j)
最後數有幾個不同的 root → 幾個省份
```

---

## 實作

python

```python
def findCircleNum(self, isConnected):
    n = len(isConnected)
    parent = list(range(n))
    rank = [0] * n

    def find(x):
        if parent[x] != x:
            parent[x] = find(parent[x])  # Path Compression
        return parent[x]

    def union(a, b):
        ra, rb = find(a), find(b)
        if ra == rb:
            return
        if rank[ra] > rank[rb]:
            parent[rb] = ra
        elif rank[ra] < rank[rb]:
            parent[ra] = rb
        else:
            parent[ra] = rb
            rank[ra] += 1

    for i in range(n):
        for j in range(n):
            if isConnected[i][j] == 1 and i != j:
                union(i, j)

    # 確保所有 path compression 完成
    for i in range(n):
        find(i)

    return len(set(parent))
```

---

## 複雜度

| | |
|---|---|
|Time|O(n²)，遍歷整個 matrix|
|Space|O(n)，parent 和 rank 陣列|

---

## 我卡在哪 / 要注意的地方

**為什麼最後要多跑一次 `find(i)`：**

Path Compression 是在 `find` 的時候才發生，如果不多跑一次，`parent` 陣列裡可能還有中間節點沒有直接指向 root：

```
union 完之後 parent 可能是：
[0, 0, 1]  ← city 2 指向 city 1，city 1 指向 city 0

set(parent) = {0, 0, 1} = {0, 1} → 算出 2 個省份，錯誤！

find(2) 觸發 path compression：
parent = [0, 0, 0]

set(parent) = {0} → 1 個省份 ✓
```

**更簡潔的計算方式（不需要最後的 find loop）：**

直接數有幾個節點的 parent 是自己：

python

```python
return sum(1 for i in range(n) if find(i) == i)
```

這樣每次 `find(i)` 都會觸發 path compression，而且語意更清楚：**root 的數量 = 省份的數量**。