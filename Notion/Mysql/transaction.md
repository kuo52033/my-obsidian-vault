---
notion-id: 8127a352-19a9-494f-88b0-5f5531af16c2
---
一個 transaction 是一個邏輯單位，其中包含多個資料庫的操作，每個 transaction 只會有 全部執行成功 (commit) or 全部不執行 (rollback) , 來解決 資料庫一致性 (database consistency) 的問題

- data define language (DDL) 無法 rollback, ex: create database/table, alter table, drop table
- 大部分 DDL 隱含著 commit 的行為，也就是執行該指令前會 commit 並終止 transaction

*The statements listed in this section (and any synonyms for them) implicitly end any transaction active in the current session, as if you had done a *[`*COMMIT*`](https://dev.mysql.com/doc/refman/5.7/en/commit.html)* before executing the statement.*

### Save Point

可以在 transaction 中插入 save point, 就可以只 rollback 到 save point 不用整個 rollback

### AutoCommit

In `InnoDB`, all user activity occurs inside a transaction. If [`autocommit`](https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html#sysvar_autocommit) mode is enabled, each SQL statement forms a single transaction on its own. By default, MySQL starts the session for each new connection with [`autocommit`](https://dev.mysql.com/doc/refman/8.0/en/server-system-variables.html#sysvar_autocommit) enabled, so MySQL does a commit after each SQL statement if that statement did not return an error.

### Isolation Level
