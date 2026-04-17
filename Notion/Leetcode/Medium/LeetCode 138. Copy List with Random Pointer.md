---
notion-id: 2b95a6e2-1812-80b3-b788-d17d999c4e5e
---
---

## 📌 **難度：Medium (6/10)**

## 📌 **面試常考程度：9/10**

這題是面試超高頻鏈表題，因為它考：

- 深拷貝 vs 淺拷貝
- random 指標處理
- O(1) 空間的巧妙技巧
- 鏈表操作的細節與邊界條件

---

# 🎯 **題意（重點）**

每個 Node 有：

- `val`
- `next`
- `random`（可指向任意 node 或 None）

請建立 **整條鏈表的深拷貝**。

拷貝後不能用到舊節點。

---

# 💡 **解法核心：三步驟 O(1) 空間技巧**

這題最重要的技巧是：

> 把 clone 的 node 插在原 node 後面，形成「交錯鏈表」
> 之後就可以用這個結構輕鬆設定 random 並拆出兩條鍊表。

---

# 🧩 **三大階段（非常經典）**

---

## **Phase 1：複製每個 node 並插入其後**

原本：

```plain text
A → B → C


```

變成：

```plain text
A → A' → B → B' → C → C'


```

clone 節點（A'）就在 A 的後面，方便下一步使用。

---

## **Phase 2：設定 clone 節點的 random**

原理：

```plain text
A'.random = A.random.next


```

因為：

- A.random 是原節點
- A.random.next 就是對應的 clone 節點

利用 interleaved 的特性，把 random 映射起來。

---

## **Phase 3：把兩條鍊表拆開（最後一步最容易寫錯）**

最終要拆成：

```plain text
Original: A → B → C
Cloned:   A' → B' → C'


```

透過雙指標 `curr`（原）、`copy`（clone）

各自跳兩步（因為 interleaved）來分離。

---

# 🧠 **完整程式碼（你的版本 + 修正拆鏈細節）**

```python
class Solution:
    def copyRandomList(self, head: 'Optional[Node]') -> 'Optional[Node]':
        if not head:
            return

        # Step 1: Insert cloned nodes
        curr = head
        while curr:
            newNode = Node(curr.val)
            temp = curr.next
            curr.next = newNode
            newNode.next = temp
            curr = temp

        # Step 2: Set random pointers
        curr = head
        while curr:
            if curr.random:
                curr.next.random = curr.random.next
            curr = curr.next.next

        # Step 3: Separate original and cloned lists
        curr = head
        copy = head.next
        newHead = copy

        while curr:
            currNext = curr.next.next
            copyNext = copy.next.next if copy.next else None

            curr.next = currNext
            copy.next = copyNext

            curr = currNext
            copy = copyNext

        return newHead


```

---

# ⏱ **時間複雜度**

### **O(n)**

三次遍歷鏈表。

---

# 📦 **空間複雜度**

### **O(1)**

沒有額外資料結構（除了少量指標）。

最優解。

---

# 📘 **總結（Notion 可用版）**

- 利用「原 → clone → 原 → clone」的交錯結構
- 可在 O(1) 空間完成 deep copy
- 分成三步：
    1. 插 clone
    2. 設 random
    3. 拆鏈表
- 必背高頻鏈表題之一