有四個等級，等級從低到高，越高越安全，但效能越差
```
Read Uncommitted 
Read Committed 
Repeatable Read ← MySQL 預設 
Serializable
```
### 要解決的問題

 - Dirty Read 髒讀，讀到尚未 commit 的資料
```
Transaction A 修改了資料但還沒 commit
Transaction B 讀到了 A 還沒 commit 的資料
A 之後 rollback
→ B 讀到的資料從來就不存在
```

- Non-Repeatable Read 不可重複讀
```
Transaction A 讀了一筆資料
Transaction B 修改了這筆資料並 commit
Transaction A 再讀一次，值不一樣了
→ 同一個 transaction 裡，同樣的查詢結果不一樣
```

-  Phantom Read 幻讀
```
Transaction A 查詢符合條件的所有資料（10 筆）
Transaction B 新增了一筆符合條件的資料並 commit
Transaction A 再查一次，變成 11 筆
→ 多出來的資料像幽靈一樣
```
### 四個 Isolation Level 各自解決什麼

| Level            | Dirty Read | Non-Repeatable Read | Phantom Read     |
| ---------------- | ---------- | ------------------- | ---------------- |
| Read Uncommitted | ❌ 有        | ❌ 有                 | ❌ 有              |
| Read Committed   | ✅ 解決       | ❌ 有                 | ❌ 有              |
| Repeatable Read  | ✅ 解決       | ✅ 解決                | ⚠️ 部分 ([[MVCC]]) |
| Serializable     | ✅ 解決       | ✅ 解決                | ✅ 解決             |

---
