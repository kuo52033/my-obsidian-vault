---
notion-id: 2975a6e2-1812-803c-aad4-fba620c7d835
---
---

### 1. 難度 (最高五星)

- **難度：** ★★★☆☆ (3/5)
- **說明：** 這是一道 "Medium" 難度中的超級經典題。它考核了你是否能將一個 O(N^3) 的問題，透過「**排序 + 雙指針**」的技巧，優化到 O(N^2)。最大的魔鬼細節在於「**如何高效且正確地去除重複答案**」。

### 2. 運用到的技巧

1. **排序 (Sorting):**
    - `nums.sort()` 是第一步，也是最關鍵的一步。
    - **花費：** $O(N \log N)$
    - **好處 1：** 讓數組有序，才可以使用「雙指針」技巧，根據 `total` 的大小來決定移動 `left` 還是 `right`。
    - **好處 2：** 讓所有相同的數字都排在一起，極大地簡化了「去除重複」的邏輯。
2. **雙指針 (Two Pointers / 雙指針法):**
    - 你將 `3Sum` 問題降維成 `1Sum + 2Sum`。
    - `**for i in range(len(nums))**`**:** 這是 `1Sum`，你用 `i` 來固定第一個數字 `current = nums[i]`。
    - `**while left < right:**`**:** 這是 `2Sum`，你在 `i` 後面的區間 `[i+1 ... len-1]` 中，尋找 `nums[left] + nums[right] == -current` 的組合。
3. **去除重複 (Deduplication):**
    - 這是本題最容易出錯的地方，你用了三道防線來處理：
    - **防線 1 (外層迴圈):** `if i > 0 and nums[i] == nums[i-1]: continue`
        - **目的：** 防止固定到「重複的 anchor」。
        - **說明：** 如果你這次固定的 `nums[i]` (例如 -1) 跟上一次的 `nums[i-1]` (也是 -1) 一樣，那麼你用這個 -1 去找 2Sum 組合，只會找到跟上一次一模一樣的答案。因此必須 `continue` 跳過。
    - **防線 2 & 3 (內層迴圈):**
        - `while left < right and nums[left] == nums[left+1]: left += 1`
        - `while left < right and nums[right] == nums[right-1]: right -= 1`
        - **目的：** 找到一組答案 `[current, nums[left], nums[right]]` 之後，防止 `left` 和 `right` 指針移到下一個仍然重複的數字上。
        - **說明：** 假設你找到了 `[-2, 1, 1]`。如果你不跳過重複，`left += 1` 後 `nums[left]` 還是 1，`right -= 1` 後 `nums[right]` 還是 1，你會重複添加 `[-2, 1, 1]`。這兩行 `while` 迴圈會幫你「跳過所有重複的 1」，直接移到下一個不同的數字。

### 3. 時間與空間複雜度

4. **時間複雜度 (Time Complexity): $O(N^2)$**
    - `nums.sort()` 花費 $O(N \log N)$。
    - 外層 `for` 迴圈跑 $O(N)$ 次。
    - 內層 `while left < right` 雙指針迴圈，對於 *每一個* `i`，`left` 和 `right` 指針最多只會互相靠近並相遇一次，所以是 $O(N)$。
    - 總共是 $O(N \log N) + O(N \times N) = O(N \log N + N^2)$。
    - 取最高項，最終時間複雜度為 **$O(N^2)$**。
5. **空間複雜度 (Space Complexity): $O(N)$ 或 $O(\log N)$**
    - 這取決於你使用的排序演算法。
    - Python 內建的 `sort()` (Timsort) 在最壞情況下需要$O(N) 的額外空間。
    - 如果只看排序之外的空間，`result` 陣列的大小取決於答案的數量，但我們通常不將「輸出」本身算入額外空間。
    - 因此，空間複雜度主要由排序決定，可視為 $O(N)$ 或 $O(\log N)$ (如果是 Quick Sort 的遞迴深度)。

---

### 4. 程式碼逐行說明 (你的程式碼)

Python

```python
class Solution:
    def threeSum(self, nums: List[int]) -> List[List[int]]:
        # 1. 排序 (O(N log N))
        nums.sort()
        result = []

        # 2. 外層迴圈：固定第一個數 nums[i] (即 current)
        for i in range(len(nums)):
            
            # 3. 防線 1：跳過重複的 anchor
            # 如果 nums[i] 和前一個數 nums[i-1] 相同，
            # 則會找到重複的組合，故跳過。
            # (i > 0 是為了防止 nums[0-1] 索引溢位)
            if i > 0 and nums[i] == nums[i-1]:
                continue

            # 將 nums[i] 作為我們固定的第一個數
            current = nums[i]
            
            # 4. 雙指針：在 i 後面的區間尋找 2Sum
            left = i + 1
            right = len(nums) - 1

            while left < right:
                # 5. 計算三數總和
                total = current + nums[left] + nums[right]
                
                # 6. 根據總和移動指針
                if total == 0:
                    # 找到了！將組合加入 result
                    result.append([current, nums[left], nums[right]])
                    
                    # 7. 防線 2：跳過 left 端的重複
                    # 必須 (left < right) 避免 left 超越 right
                    while left < right and nums[left] == nums[left+1]:
                        left += 1
                    
                    # 8. 防線 3：跳過 right 端的重複
                    while left < right and nums[right] == nums[right-1]:
                        right -= 1
                    
                    # 移到下一個 "不重複" 的位置
                    left += 1
                    right -= 1
                
                elif total > 0:
                    # 總和太大，表示 right 太大了，向左移
                    right -= 1
                else: # total < 0
                    # 總和太小，表示 left 太小了，向右移
                    left += 1
        
        return result
```
