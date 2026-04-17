---
notion-id: 2995a6e2-1812-80d0-8bff-d9bf5e5c1c2c
---
### 1. 難度 (最高五星)

- **難度：** ★★★☆☆ (3/5)
- **說明：** 這是一道 "Medium" 難度中的經典必考題。它考察的是你對「二分搜尋法 (Binary Search)」的理解是否透徹，以及你是否能處理好陣列旋轉後的「非單調性」(non-monotonic)。

### 2. 運用到的技巧

1. **二分搜尋法 (Binary Search):**
    - 這是解題的基礎，你使用了 `left`, `right`, `mid` 指針，並以 $O(\log N)$ 的方式縮小搜索範圍。
2. **分治法 (Divide and Conquer):**
    - 這是你程式碼的精髓所在。在 `while` 迴圈的每一步，你都做了以下判斷：
    - **關鍵洞察：** 在一個旋轉過的陣列中，當你用 `mid` 切開時，`[left...mid]` 和 `[mid...right]` 這兩半中，**必定有一半是「完全有序」的**。
    - **你的策略：**
        1. 先找出「哪一半是有序的」。
        2. 再判斷 `target` 是否在「那一半有序的區間」內。
        3. 如果在，就去搜那一半 (這是標準的二分搜尋)。
        4. 如果不在，就把問題丟給「另一半無序的區間」去遞迴處理。

### 3. 核心邏輯分析 (你的程式碼)

3. **找出「有序」的那一半:**
    - `if nums[mid] >= nums[left]:`
    - 這一行判斷的是**「左半邊 `[left...mid]` 是否有序」**。
    - **(關鍵細節 1):** 這裡的 `>=` 非常重要！
        - 為什麼要 `_=`？ 考慮 `[3, 1]` 這種情況，`left=0`, `mid=0`。此時 `nums[mid] == nums[left]` (3 == 3)，左半邊 `[3]` 確實是有序的。如果漏了 `=`，程式會錯誤地跑到 `else` 區塊。
4. **情況一：**`**[left...mid]**`** 是有序的**
    - `if nums[mid] > target and nums[left] <= target:`
    - **(關鍵細節 2):** 這裡的 `<=` 非常重要！
        - 你判斷 `target` 是否落在 `[nums[left]...nums[mid])` 這個區間內。
        - `nums[left] <= target` 確保了如果 `target` 剛好等於 `nums[left]`，我們能正確地往左搜尋 (因為 `right = mid - 1` 會把 `mid` 丟掉，所以 `if` 條件必須包含 `target` 在 `left` 的情況)。
    - `else: left = mid + 1`
        - 如果 `target` 不在有序的左半邊 (可能 `target > nums[mid]` 或 `target < nums[left]`)，那它*必定*在無序的右半邊。
5. **情況二：**`**else**`** (表示 **`**[mid...right]**`** 是有序的)**
    - `if nums[mid] < target and nums[right] >= target:`
    - **(關鍵細節 3):** 這裡的 `>=` 非常重要！
        - 你判斷 `target` 是否落在 `(nums[mid]...nums[right]]` 這個區間內。
        - `nums[right] >= target` 確保了如果 `target` 剛好等於 `nums[right]`，我們能正確地往右搜尋。
    - `else: right = mid - 1`
        - 如果 `target` 不在有序的右半邊，那它*必定*在無序的 左半邊。

### 4. 時間與空間複雜度

6. **時間複雜度 (Time Complexity): $O(\log N)$**
    - $N$ 是 `nums` 的長度。
    - 你的演算法在每一步都將搜索範圍縮小了一半，這是標準的二分搜尋法複雜度。
7. **空間複雜度 (Space Complexity): $O(1)$**
    - 你只使用了 `left`, `right`, `mid` 三個變數，空間是固定的常數。

---

### 程式碼逐行說明 (你的程式碼)

Python

```python
class Solution:
    def search(self, nums: List[int], target: int) -> int:
        left = 0
        right = len(nums) - 1
        
        # 1. (關鍵細節 4): 
        # 必須是 <=，才能處理 left 和 right 重疊 (只剩一個元素) 的情況
        while left <= right:
            mid = (right + left) // 2

            # 2. 找到了，直接返回
            if nums[mid] == target:
                return mid
            
            # 3. 關鍵判斷：左半邊 [left...mid] 是有序的
            # (注意：這裡的 >= 至關重要，處理 [3,1] mid=0 的情況)
            if nums[mid] >= nums[left]:
                
                # 4. Target 在 "有序的左半邊" 區間內
                # 條件: (target 在 left 右邊) 且 (target 在 mid 左邊)
                # (注意：nums[left] <= target 很重要)
                if nums[mid] > target and nums[left] <= target:
                    right = mid - 1 # 往左半邊搜
                else:
                    # Target 在 "無序的右半邊"
                    left = mid + 1 # 往右半邊搜
            
            # 5. 否則，表示右半邊 [mid...right] 是有序的
            else:
                
                # 6. Target 在 "有序的右半邊" 區間內
                # 條件: (target 在 mid 右邊) 且 (target 在 right 左邊)
                # (注意：nums[right] >= target 很重要)
                if nums[mid] < target and nums[right] >= target:
                    left = mid + 1 # 往右半邊搜
                else:
                    # Target 在 "無序的左半邊"
                    right = mid - 1 # 往左半邊搜

        # 7. 迴圈結束都沒找到
        return -1
```