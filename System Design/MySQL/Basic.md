### ACID

**A- Atomicity 原子性**
```bash
一個 transaction 裡的所有操作，要嘛全部成功，要嘛全部失敗。

例子：轉帳
Step 1: A 帳戶 -1000
Step 2: B 帳戶 +1000

Step 1 成功，Step 2 失敗
→ 沒有 Atomicity：A 少了 1000，B 沒有收到
→ 有 Atomicity：整個 transaction rollback，兩個都不變
```

C - Consistency 一致性
```bash
Transaction 執行前後，資料庫都必須符合所有定義的規則。

例子：帳戶餘額不能是負數
A 帳戶只有 500，卻要轉 1000
→ 違反 Consistency，資料庫拒絕這個 transaction
```

I - [[Isolation]] 隔離性
```
多個 transaction 同時執行，互相不干擾。
就像每個 transaction 都是獨立執行的一樣。
```

D - Durability 持久性
```bash
Transaction commit 之後，資料永久寫入。
即使系統 crash、斷電，資料也不會消失。

實作方式：Write-Ahead Log（WAL）
→ 先寫 log，再寫資料
→ crash 後可以從 log 恢復
```
