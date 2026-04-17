---
notion-id: 31858313-a0f8-4380-86d9-9a923a565bf4
---
Database normalization is a process used to organize a database into tables and columns. The main idea with this is that a table should be about a specific topic and only supporting topics included. The purpose of normalization is to eliminate redundant data (storing the same data in more than one table) and ensure data dependencies make sense (only storing related data in a table). Both of these are worthy goals as they reduce the amount of space a database consumes and ensure that data is logically stored.

### 1NF

- 一個欄位不存一個以上的值
- 每個 row 必須為 unique，系統生成的 pk，或自己建的 unique key
- column name 必須 unique

### 2NF

- 所有 column 資料必須依賴於 pk

### 3NF

- pk 定義了所有 non-key column，non-key column 不依賴於其他 key