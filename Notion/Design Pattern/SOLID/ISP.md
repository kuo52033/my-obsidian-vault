---
notion-id: 2b0f7e6f-ef47-42ff-839c-96ed0b1e6ff0
---
### ISP ( Inteface Segregation Principle ) 介面隔離原則

> [!tip] 💡
> 不應該讓 client 依賴他們用不到的方法，避免誤用。

- 一個 class 或 module 沒必要 public 就用 private
- 設計 class 以 [ 它可以做什麼 ] 而不是 [ 它是甚麼 ]
- 跟 SRP 蠻類似的，一個類別只有一種角色會引起變化，也就是只有這個角色能使用這個類別 