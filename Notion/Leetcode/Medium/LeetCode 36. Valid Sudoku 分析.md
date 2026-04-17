---
notion-id: 29a5a6e2-1812-8062-b7d9-d1b75f4ccd6a
---
### 1. 難度 (最高五星)

- **難度：** ★★☆☆☆ (2/5)
- **說明：** 這是一道 "Medium" 難度的題目。它的難點不在於演算法多麼複雜，而在於你是否能想出一個**有條理、不重複**的方法，去檢查總共 27 個區域 (9 行 + 9 列 + 9 宮格)。

### 2. 運用到的技巧

1. `**collections.defaultdict(set)**`**:**
    - 這是你新採用的技巧，也是本解法的亮點。
    - `defaultdict` 是一個特殊的字典，它接受一個「工廠函式」(在這裡是 `set`)。
    - 當你試圖存取一個*不存在*的 Key 時 (例如 `ht["row_0"]`)，它不會報錯 (KeyError)，而是會**自動呼叫 **`**set()**`** 產生一個空集合**，並將其設為 `ht["row_0"]` 的值，然後返回給你。
    - 這完美地簡化了「檢查 Key 是否存在，不存在則初始化」的邏輯。
2. **雜湊表 (Hash Map) + 集合 (Set):**
    - 你仍然是使用 Hash Map (字典) 來儲存狀態，並使用 Set (集合) 來利用 $O(1)$ 的「查找」和「新增」特性來檢查重複。
3. **唯一的 Key 生成 (Unique Key Generation):**
    - 這是解法的核心創意。你用 `f"row_{i}"`, `f"col_{j}"`, `f"{i//3}_{j//3}"` 這三種格式，產生了 27 個獨一無二的 Key，讓你可以在一個 `ht` 裡同時追蹤三種不同的規則。

### 3. 時間與空間複雜度

( $N$ 是數獨的邊長，這裡 $N=9$ )

4. **時間複雜度 (Time Complexity): $O(N^2)$ 或 $O(1)$**
    - 你遍歷了 $N \times N$ (即 $9 \times 9 = 81$) 個格子。
    - 迴圈內的 `defaultdict` 存取、`set` 查找 (`in`)、`set` 新增 (`add`) 都是 $O(1)$ (平均) 操作。
    - 總時間 = $O(N^2)$。
    - 因為 $N=9$ 是固定的常數，所以也可以視為 $O(1)$。
5. **空間複雜度 (Space Complexity): $O(N^2)$ 或 $O(1)$**
    - `ht` 最多會儲存 27 個 Key (9 rows, 9 cols, 9 boxes)。
    - 每個 Key 對應的 set 最多儲存 9 個數字。
    - 總儲存量級為 $O(N^2)$。
    - 同樣，因為 $N=9$ 是固定的，所以也可以視為 $O(1)$。

---

### 程式碼逐行說明 (你的 `defaultdict` 版本)

Python

```python
# 1. 導入 collections 模組
import collections

class Solution:
    def isValidSudoku(self, board: List[List[str]]) -> bool:
        
        # 2. 建立一個 defaultdict
        #    當我們存取一個不存在的 key 時，它會自動建立一個空 set()
        ht = collections.defaultdict(set)

        # 3. 遍歷 9x9 的棋盤
        for i in range(9): # i (row)
            for j in range(9): # j (column)
                
                # 4. 取得當前格子的值
                val = board[i][j]

                # 5. 檢查是否為空
                #    用 "if val == '.'" 是非常明確的好寫法
                if val == ".":
                    continue
                
                # 6. 產生三個 "唯一 Key"
                row = f"row_{i}"
                col = f"col_{j}"
                box = f"{i//3}_{j//3}" # 巧妙利用整數除法

                # 7. 檢查重複 (核心邏輯)
                #    感謝 defaultdict，我們不需要檢查 key 是否存在，
                #    直接存取 ht[row] 即可。
                if val in ht[row] or val in ht[col] or val in ht[box]:
                    return False
                
                # 8. 如果沒有重複，就把 "val" 加入這三個 Set 中
                #    同樣，直接 add，不用擔心 key 不存在
                ht[row].add(val)          
                ht[col].add(val)
                ht[box].add(val)

        # 9. 遍歷完畢，沒有發現重複，返回 True
        return True
```