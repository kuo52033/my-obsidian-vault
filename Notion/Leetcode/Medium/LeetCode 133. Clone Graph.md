---
notion-id: 2b65a6e2-1812-803b-a3d8-c72155b7ba70
---
---

## 📌 **面試常考程度：8/10**

相當高頻，特別是：

- Graph traversal
- 深/廣搜尋
- HashMap 做「舊 → 新」映射
- 處理無向圖、有可能有 cycles

幾乎是 BFS/DFS + HashMap 的經典面試題。

---

## 📌 **難度：6/10（Medium）**

觀念簡單，但容易寫錯：

- 不小心 infinite loop
- node identity vs node.val
- 深拷貝 vs 淺拷貝

---

# 🎯 **題意（重點）**

給一張圖的某一個節點（無向、可能有 cycle），請完整 clone 這張圖，且每個 Node 都要深拷貝。

---

# 💡 **核心思路：BFS/DFS + HashMap 映射**

**node_dict: old.val → new Node**

流程：

1. 建立 root 的副本
2. BFS / DFS 探索整張圖
3. 在 mapping 裡找不到 → 建立新節點
4. 將 clone 的 node 與 clone 的 neighbors 建立連結

**避免重複建立，也避免 infinite loop。**

---

# 🧩 **程式碼解析（你的寫法，BFS 解）**

```python
from collections import deque
from typing import Optional

class Solution:
    def cloneGraph(self, node: Optional['Node']) -> Optional['Node']:
        if not node:
            return

        # mapping: old node val → new node object
        node_dict = {
            node.val: Node(node.val)
        }

        q = deque([node])

        while len(q):
            n = q.popleft()

            for nb in n.neighbors:
                # 如果 neighbor 沒 clone 過 → 建立 clone，放入 queue
                if nb.val not in node_dict:
                    node_dict[nb.val] = Node(nb.val)
                    q.append(nb)

                # 建立新節點的 neighbor 關係
                node_dict[n.val].neighbors.append(node_dict[nb.val])

        return node_dict[node.val]


```

---

# ✔️ **代碼優點**

- 使用 BFS → 不會爆 recursion depth
- HashMap 做 mapping → 避免 cycle infinite loop
- 清楚易懂，標準解

---

# ⚠️ **重要注意點**

### 這題推薦使用 **Node object 做 key，而不是 node.val**

因為題目並未保證：

- val 一定 unique

但 LeetCode 測資 val 是唯一沒錯。

若面試遇到相同題，你應該這樣寫：

```python
node_dict = {node: Node(node.val)}


```

用 node 物件當 key，才是更通用的寫法。

---

# 🔄 **DFS 解法（更短）**

```python
class Solution:
    def cloneGraph(self, node):
        if not node:
            return

        mapping = {}

        def dfs(n):
            if n in mapping:
                return mapping[n]

            copy = Node(n.val)
            mapping[n] = copy

            for nb in n.neighbors:
                copy.neighbors.append(dfs(nb))

            return copy

        return dfs(node)


```

---

# ⏱ **時間複雜度**

- 每個節點、每條邊都只走一次

### 👉 **O(V + E)**

---

# 📦 **空間複雜度**

- HashMap 存每個 clone 節點 → O(V)
- BFS/DFS queue/stack → 最差 O(V)

### 👉 **O(V)**

---

# ❗補充：面試常問

5. **如果 val 不是 unique？**
→ Mapping 必須用 Node object 當 key
6. **graph 有 cycle 怎麼辦？**
→ HashMap 是為了避免重複 clone & infinite loop
7. **DFS vs BFS 差在哪？**
→ 兩者皆可，本質一樣；BFS 不會 stack overflow
8. **為什麼不能直接複製 pointer？**
→ 會變成 shallow copy，不是 deep clone

---

# ✅ **Notion 筆記總結（可直接貼）**

**Clone Graph = BFS/DFS + HashMap (old → new)**

避免 cycle、避免重複 clone，是圖遍歷的標準模版題。