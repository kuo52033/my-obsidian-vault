---
notion-id: 365b0e3f-1900-4d49-a024-10d1ca628b1e
---
- shared lock ( s lock) 
    - 讀讀共享，讀寫互斥
- exclusive lock (x lock)
    - 寫寫互斥，讀寫互斥
- row lock
    - update, delete 操作也會加 row lock (x lock)
    - 在 mysql Repeatable Read ( default ) 隔離等級下，有分三種 row lock，Record lock (記錄鎖)、 Gap lock (間隙鎖)、Next-Key lock (記錄鎖+間隙鎖)
    - record lock : 只鎖住一筆資料，有分 x lock 以及 s lock
    - gap lock : 鎖定一個範圍，為了避免幻讀發生，在 id = (3, 5) 加上間隙鎖，代表無法插入 id=4 的資料 (前開後開)
    - next-key lock : 鎖定一個範圍，並且鎖定記錄本身，(3, 5] 的 next-key lock ，代表無法插入 id=4 的資料，也不能動 id=5 (前開後閉合)
- table lock
- intention lock

## How to lock

加鎖的基本單位是 next-key lock ，並且是加在索引上的，但如果使用 record lock 及 gap lock 就能避免幻讀的話， next-key 會退化成那兩種

```sql
select * from performance_schema.data_locks\G;
// 用以分析加了什麼鎖
```

### Primary key equal search 

記錄存在: 在該記錄上加 record key

記錄不存在: 先找尋範圍右界線，再左界線，產生一個 gap key 

ex:

```sql
select * from user where id = 2 for update;
//假如 id=2 存在，record key on primary key id=2
//假如 id=2 不存在，gap key on (1,5) 
```

### Primary key range search 

執行範圍搜尋時，會對每一個掃描到的 index 加上 next-key lock ，會依照情況退化成 gap lock 或 record lock

| id | name | age |
| --- | --- | --- |
| 1 | test1 | 10 |
| 5 | test5 | 20 |
| 7 | test7 | 30 |
| 15 | test15 | 35 |
| 20 | test20 | 40 |

```sql
select * from user where id > 15 for update;

// (15, 20] next-key lock
// (20, +∞] next-key lock

select * from user where id >= 15 for update;

// 15 record key 
// (15, 20] next-key lock
// (20, +∞] next-key lock
```