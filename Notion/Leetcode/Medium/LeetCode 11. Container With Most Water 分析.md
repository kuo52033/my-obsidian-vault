---
notion-id: 2965a6e2-1812-8036-8dcf-f025db861791
---
### 1. 難度 (最高五星)

- **難度：** ★★★☆☆ (3/5)
- **說明：** 這是一道非常經典的 "Medium" 題目。它的難點不在於程式碼的複雜度（程式碼本身很短），而在於**想通「為什麼移動較短的那根板子」是正確的**。暴力解法 ( $O(N^2)$ ) 很容易想，但 $O(N)$ 的雙指針解法則需要一點洞察力。

### 2. 運用到的技巧

1. **雙指針 (Two Pointers):**
    - 這是解決本題的核心技巧。你初始化 `left = 0` 和 `right = len(height) - 1`，讓兩個指針分別指向陣列的「最左邊」和「最右邊」。
    - 這兩個指針共同定義了一個「容器」的寬度 (`right - left`)。
2. **貪心法 (Greedy Approach):**
    - 你的移動策略是貪心的。在每一步，你都計算*當前* `[left, right]` 構成的容器面積，並更新 `max_water`。
    - 然後，你做出一個「局部最優」的決策：**移動指向較短板子的那個指針**。

### 3. 核心邏輯詳解 (你寫法的精妙之處)

為什麼你的 `if height[left] <= height[right]: left += 1` 這行是正確的？

- **容器面積：** $Area = \text{width} \times \text{height} = (right - left) \times \min(height[left], height[right])$
- **當前狀態：** 假設 `height[left]` (5) **<=** `height[right]` (8)。
    - `width = right - left`
    - `height = height[left]` (因為 5 < 8)
    - $Area = (right - left) \times height[left]$
- **決策：** 我們現在要移動 `left` 還是 `right` 來尋找 *可能* 的更大面積？
    1. **選項 A：移動 **`**right**`** ( **`**right -= 1**`** )**
        - 新的寬度：`width - 1` (變小了)
        - 新的高度：$\min(height[left], height[right-1])$。因為 `height[left]` (5) 仍然是候選板子，新的高度 *最多* 還是 5 (如果 `height[right-1]` > 5)，甚至可能更小 (如果 `height[right-1]` < 5)。
        - **結論：** 寬度變小了，高度最高也只能持平 (或變小)。所以 $Area$ **絕對不可能變大**。移動 `right` 是沒有意義的。
    2. **選項 B：移動 **`**left**`** ( **`**left += 1**`** ) (你的作法)**
        - 新的寬度：`width - 1` (變小了)
        - 新的高度：$\min(height[left+1], height[right])$。
        - **結論：** 雖然寬度變小了，但我們的「短板」`height[left]` 已經被換掉了。如果新的 `height[left+1]` 非常高 (例如 10)，那麼新的高度就可能變成 $\min(10, 8) = 8$。
        - **這給了我們一個「高度增加」的 *****可能性*****，這個高度的增加 *****有機會***** 彌補寬度的損失**，從而創造出更大的面積。
- **總結：** 我們總是移動**較短的那根板子**，因為它是當前容器的「瓶頸」。保留這根短板子並移動長板子，面積絕不會增加。反之，**丟棄這根短板子**，我們才 *有機會* 找到一個更高的板子來組成更大的面積。

### 4. 時間與空間複雜度

3. **時間複雜度 (Time Complexity): $O(N)$**
    - $N$ 是 `height` 陣列的長度。
    - `left` 指針從頭開始向右移動，`right` 指針從尾巴開始向左移動。
    - `while left < right` 迴圈在 `left` 和 `right` 相遇時停止。
    - 兩個指針總共只會遍歷一次陣列，所以時間複雜度是 $O(N)$。
4. **空間複雜度 (Space Complexity): $O(1)$**
    - 你只使用了 `left`, `right`, `max_water` 這幾個變數，它們佔用的空間是固定的，與輸入大小 $N$ 無關。

### 5. 程式碼逐行說明

Python

```python
class Solution:
    def maxArea(self, height: List[int]) -> int:
        
        # 1. 初始化雙指針
        left = 0 # 左指針，從最左邊開始
        right = len(height) - 1 # 右指針，從最右邊開始
        
        # 儲存目前找到的最大面積
        max_water = 0

        # 2. 開始遍歷
        # 當左指針還在右指針的左邊時，繼續搜索
        while left < right:
            
            # 3. 計算當前面積
            # 寬度 = right - left
            # 高度 = 兩根板子中較短的那一根
            current_width = right - left
            current_height = min(height[right], height[left])
            current_area = current_width * current_height
            
            # 更新最大值
            max_water = max(max_water, current_area)
            
            # 4. 移動指針 (核心邏輯)
            # 判斷哪根板子比較短
            if height[left] <= height[right]:
                # 左邊板子是瓶頸（或一樣高），
                # 移動左指針，才"有機會"找到更高的左板子
                left += 1
            else:
                # 右邊板子是瓶頸，
                # 移動右指針，才"有機會"找到更高的右板子
                right -= 1
        
        # 5. 返回結果
        return max_water
```