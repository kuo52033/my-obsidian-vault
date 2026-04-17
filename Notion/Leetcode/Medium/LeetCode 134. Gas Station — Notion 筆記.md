---
notion-id: 2b85a6e2-1812-80c8-9081-ecf2ecd7f38f
---
---

## 📌 題意簡述

你有一圈加油站，第 i 站：

- **gas[i]**：在此站可以加到的油
- **cost[i]**：開到下一站需要的油

問：

**是否存在一個起點，使你能繞完整圈？**

若有，回傳該起點 index；否則回傳 -1。

---

## 📌 關鍵觀念（貪心 Greedy）

### **1. 若總油量 < 總耗油 → 一定無解**

```plain text
sum(gas) < sum(cost) → 回傳 -1
```

### **2. 若從某段途中油量變負數 → 這段內的任何點都不能當起點**

因為：

如果從 A → B 途中油量變成負數，

代表 **A～B 任一站當起點都會更糟**（油更少），

所以直接把起點跳到 `B + 1`。

---

## 📌 解法流程（Greedy）

1. 用 `totalCost` 統計整體是否可行
2. 用 `currGas` 記當前油量
3. 一旦 `currGas < 0`
→ 重設 currGas = 0
→ 起點設為下一站

---

# 🧩 程式碼解析（你的版本，正確、最優解）

```python
class Solution:
    def canCompleteCircuit(self, gas: List[int], cost: List[int]) -> int:
        currGas = 0
        start = 0
        totalCost = 0

        for i in range(len(gas)):
            remain = gas[i] - cost[i]
            currGas += remain
            totalCost += remain

            # 無法從 start 抵達 i+1 → 換起點
            if currGas < 0:
                start = i + 1
                currGas = 0

        return -1 if totalCost < 0 else start


```

---

## ✔️ 你的程式碼的重點

- `currGas` < 0 → 把起點更新到下一站
- `totalCost` 用來判斷大局是否可環島
- 時間複雜度 O(n)
- 空間 O(1)
- 已是 **最優解**，無需改進

---

# 📈 時間複雜度

### **O(n)**

只遍歷一次陣列。

---

# 📦 空間複雜度

### **O(1)**

使用常數變數。

---

## 📝 補充理解（簡短版）

- 若全程總油量足夠 → 一定能找到唯一解
- Greedy 的本質：
**紀錄連續區間「能撐多久」，一旦撐不住，就從下一站重新開始**

---

# ✅ Notion 筆記總結（可直接貼）

- 判斷是否可環島 → `sum(gas) >= sum(cost)`
- 途中 `currGas < 0` → 這段起點都不行 → 更新起點
- O(n) 最優解