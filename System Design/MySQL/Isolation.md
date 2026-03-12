有四個等級，等級從低到高，越高越安全，但效能越差
```
Read Uncommitted 
Read Committed 
Repeatable Read ← MySQL 預設 
Serializable
```
### 要解決的問題

 - Dirty Read 髒讀
	```
	Transaction A 修改了資料但還沒 commit
	Transaction B 讀到了 A 還沒 commit 的資料
	A 之後 rollback
	→ B 讀到的資料從來就不存在
	```
	
