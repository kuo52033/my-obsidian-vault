### ACID

**A- Atomicity 原子性**
```
一個 transaction 裡的所有操作，要嘛全部成功，要嘛全部失敗。

例子：轉帳
Step 1: A 帳戶 -1000
Step 2: B 帳戶 +1000

Step 1 成功，Step 2 失敗
→ 沒有 Atomicity：A 少了 1000，B 沒有收到
→ 有 Atomicity：整個 transaction rollback，兩個都不變
```
