---
notion-id: 2955a6e2-1812-80df-8fc0-dec2054677ff
---
### 1. 難度

- **難度：** ★★☆☆☆ (2/5)
- **說明：** 這是 LeetCode 上的 "Medium" 題目，但它也是「滑動窗口」(Sliding Window) 技巧最經典的入門題。一旦理解了滑動窗口的概念，這題的邏輯就相對直接。

### 2. 運用到的技巧

1. **滑動窗口 (Sliding Window):**
    - 這是解決這題的核心技巧。我們使用兩個指針，`left` 和 `right`，來定義一個「窗口」`[left, right]`。
    - `right` 指針負責向右擴展窗口，探索新的元素。
    - `left` 指針負責在窗口不符合條件時 (在這裡是「出現重複字元」) 向右收縮窗口。
    - 我們在窗口滑動的過程中，不斷更新我們需要的答案 (最長的長度)。
2. **集合 (Set):**
    - `chr_set` 用來儲存目前「窗口」內所有的 *不重複* 字元。
    - 使用 Set 的好處是它提供了平均 $O(1)$ 時間複雜度的「新增」(`add`)、「刪除」(`remove`) 和「查找」(`in`) 操作，這對滑動窗口的效率至關重要。

### 3. 時間與空間複雜度

3. **時間複雜度 (Time Complexity): $O(N)$**
    - $N$ 是輸入字串 `s` 的長度。
    - 分析：`right` 指針從頭到尾遍歷一次字串，花費 $O(N)$。`left` 指針也只會從頭到尾移動一次 (它絕不會向左回退)。
    - 雖然 `while` 迴圈看起來像是巢狀迴圈，但 `left` 指針的移動總和最多也是 $N$ 次。因此，每個字元最多被 `add` 進 `chr_set` 一次，也最多被 `remove` 出 `chr_set` 一次。
    - 總體來看，`left` 和 `right` 指針總共移動了 $2N$ 次，所以時間複雜度為 $O(2N)$，簡化為 $O(N)$。
4. **空間複雜度 (Space Complexity): $O(k)$**
    - $k$ 是字元集 (Character Set) 的大小。
    - 分析：`chr_set` 用來儲存窗口中的字元。在最壞的情況下，窗口中可能包含了所有不重複的字元。
    - 如果字串只包含 ASCII 字元， $k$ 最大是 128 或 256 (常數)。
    - 如果字串是 Unicode， $k$ 可能會更大。在 LeetCode 的情境下，通常可以假設 $k$ 是一個有上限的常數，此時空間複雜度可視為 $O(1)$。
    - 更精確的說法是 $O(\min(N, k))$，因為 `chr_set` 的大小不會超過字串長度 $N$，也不會超過字元集的大小 $k$。

### 4. 程式碼逐行說明

這是你提供的程式碼，加上了詳細的註解來說明每一步：

Python

```python
class Solution:
    def lengthOfLongestSubstring(self, s: str) -> int:
        
        # 1. 初始化
        # chr_set 用來存放當前 "窗口" 內的不重複字元
        chr_set = set()
        
        # left 是窗口的左邊界 (包含)
        left = 0
        
        # max_len 用來記錄我們找到的最長子字串長度
        max_len = 0
        
        # 2. 開始滑動窗口
        # right 是窗口的右邊界 (包含)，它會遍歷整個字串
        for right in range(0, len(s)):
            
            # 3. 檢查條件並收縮窗口
            # 檢查 s[right] (即將要加入窗口的新字元) 是否已經存在於 set 中
            # 如果存在，表示我們遇到了重複字元
            while s[right] in chr_set:
                # 為了消除重複，我們必須從 "左邊" 開始收縮窗口
                # 移除窗口最左邊的字元 s[left]
                chr_set.remove(s[left])
                
                # 將左邊界 left 向右移動一格
                left += 1
            
            # 4. 擴展窗口並更新狀態
            # 當 while 迴圈結束時，代表 s[right] 已經不在窗口內 (set 中)
            # 這時，我們可以安全地將 s[right] 加入 set
            chr_set.add(s[right])
            
            # 5. 更新最大長度
            # 當前窗口的長度是 (right - left + 1)
            # 因為 chr_set 裡存放的就是當前窗口內的不重複字元，
            # 所以 len(chr_set) 也等於當前窗口的長度
            max_len = max(max_len, len(chr_set))
            # (使用 max(max_len, right - left + 1) 也是一樣的)
            
        # 6. 返回結果
        # 遍歷完畢後，max_len 即為所求
        return max_len
```
