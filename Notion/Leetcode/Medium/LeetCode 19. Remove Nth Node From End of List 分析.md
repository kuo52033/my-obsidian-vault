---
notion-id: 2995a6e2-1812-80ce-a6ef-f60d4729dcba
---
### 1. 難度 (最高五星)

- **難度：** ★★☆☆☆ (2/5)
- **說明：** 這是一道 "Medium" 難度的題目，但它也是 Linked List 必考的經典題型。難點在於如何在「一次遍歷」中，巧妙地定位到「倒數第 N 個」節點的「前一個」節點。

### 2. 運用到的技巧

1. **虛擬頭節點 (Dummy Head):**
    - `dummy = ListNode()`
    - `dummy.next = head`
    - 這是你程式碼中的*第一個*精妙之處。
    - **目的：** 統一所有節點的刪除邏輯。
    - 如果沒有 `dummy`，當你要刪除的是「倒數第 5 個節點」（剛好是 `head`）時，你的 `slow` 指針會無處可停（它沒有「前一個」節點）。
    - 有了 `dummy`，`slow` 和 `fast` 都從 `dummy` 出發，即使要刪除的是 `head`，`slow` 最終也會停在 `dummy` 上，讓你能夠安全地執行 `dummy.next = dummy.next.next`。
2. **雙指針 (Two Pointers / 快慢指針):**
    - `slow` 和 `fast`。
    - 這是你程式碼中的*第二個*精妙之處。
    - **目的：** 透過「距離差」來定位。

### 3. 核心邏輯分析 (你的程式碼)

3. **建立「距離差」:**
    - `for _ in range(n): fast = fast.next`
    - 你先讓 `fast` 指針往前跑 $n$ 步。
    - **結果：** `fast` 和 `slow` 之間產生了一個固定 $n$ 格的「距離」。
4. **同時移動，保持距離:**
    - `while fast.next is not None:`
    - 接著，你讓 `fast` 和 `slow` *一起* 往前跑，一步一步走。
    - **關鍵點：** 為什麼是 `while fast.next is not None`？
        - 因為你要讓 `fast` 停在「**最後一個節點**」上 (而不是 `Null`)。
    - **舉例：** `[1,2,3,4,5], n=2`
        - `dummy` -> `1` -> `2` -> `3` -> `4` -> `5`
        - `fast` 先走 2 步 (`n=2`)，停在 `2`。
        - `slow` 還在 `dummy`。
        - **開始 **`**while**`** 迴圈：**
            - `fast` 移到 `3`，`slow` 移到 `1`。
            - `fast` 移到 `4`，`slow` 移到 `2`。
            - `fast` 移到 `5`，`slow` 移到 `3`。
        - `fast` 在 `5`，`fast.next` 是 `None`，迴圈停止。
    - **結果：** 當 `fast` 停在「最後一個節點」(5) 時，`slow` 剛好停在「**倒數第 n+1 個節點**」(3)，也就是「**目標節點(4)的前一個**」。
5. **執行刪除:**
    - `slow.next = slow.next.next`
    - 你將 `slow` (節點 3) 的 `next`，指向 `slow.next` (節點 4) 的 `next` (節點 5)。
    - `3.next = 5`，節點 4 就這樣被「跳過」並刪除了。
6. **返回結果:**
    - `return dummy.next`
    - 你返回 `dummy.next` 而不是 `head`，因為 `head` (節點 1) 本身有可能已經被刪除了。`dummy.next` 永遠會指向 list 真正的頭部。

### 4. 時間與空間複雜度

7. **時間複雜度 (Time Complexity): $O(L)$**
    - $L$ 是 Linked List 的總長度。
    - `fast` 指針總共從 `dummy` 走到了最後一個節點，總共走了 $L$ 步。`slow` 指針走了 $L - n$ 步。
    - 總操作次數與 $L$ 成正比。這是一個「一次遍歷」演算法。
8. **空間複雜度 (Space Complexity): $O(1)$**
    - 你只使用了 `dummy`, `slow`, `fast` 三個額外的指針，佔用的空間是固定的常數。

---

### 程式碼逐行說明 (你的程式碼)

Python

```python
class Solution:
    def removeNthFromEnd(self, head: Optional[ListNode], n: int) -> Optional[ListNode]:
        
        # 1. 建立虛擬頭節點，用來處理 "刪除 head" 的邊界情況
        dummy = ListNode()
        dummy.next = head
        
        # 2. 初始
        slow = dummy
        fast = dummy
        
        # 3. 讓 fast 指針先往前走 n 步
        # 這樣 fast 和 slow 之間就有了 n 個節點的差距
        for _ in range(n):
            fast = fast.next
        
        # 4. 同時移動 fast 和 slow
        # 直到 fast 走到 "最後一個" 節點 (注意：不是 None)
        while fast.next is not None:
            fast = fast.next
            slow = slow.next
        
        # 5. 執行刪除
        # 此時，fast 在 "最後一個節點"
        # slow 則剛好在 "要被刪除的節點" 的 "前一個節點"
        # (slow -> target_node -> target_node.next)
        # (slow.next = slow.next.next)
        slow.next = slow.next.next

        # 6. 返回 dummy.next
        # 因為 head 節點可能已經被刪除了，
        # 所以 dummy.next 才是 list 真正的頭
        return dummy.next
```
