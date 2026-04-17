---
notion-id: a73cb707-e6b4-4678-a52c-c764b8591cc0
---
### 1. forEach : 不會回傳值，無法從中跳出迴圈，for才可以。function 可有3個參數( 內容物、index、原陣列)

### 2. map : 會回傳一個與原本陣列相同長度的陣列。

### 3. filter: 根據 function return true or false 來判斷是否回傳該物件，最終回傳過濾出的結果。

### 4. findIndex: 根據function 比對陣列每個元素，並回傳第一個符合條件的 index

###     (find 方法則回傳該陣列元素)

### 5. reduce: function主要使用兩個變數( acc，cur)，可加入第二個參數為第一個acc，每一次return 會傳給下一次的 acc，而cur 則為當前陣列元素。如果沒指定initial acc 則從陣列第一個元素開始，cur 則為第二個元素開始。

### 6. sort: function 有兩個參數 (a、b)，如果回傳正數，a 要排在 b 後面，回傳負數 a 則在 b 前面，回傳0則不變。
