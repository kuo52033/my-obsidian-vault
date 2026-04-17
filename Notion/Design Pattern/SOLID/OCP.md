---
notion-id: c75194e2-9fd8-4161-a286-81f254fa6256
---
### OCP ( Open-Closed Principle ) 開放封閉原則 

[ 一個軟體應該對於擴展是開放的，且對於修改是封閉的 ] / [ 當有新功能時，會希望以 plugin 的方式家新功能，而不是修改原本的程式 ]

這個原則的主要目的為避免新增新功能時，去修改舊的程式碼，造成出錯。

相關設計模式

- 策略模式 ( Strategy Pattern )
- 配接器模式 ( Adapter Pattern )
- 觀察者模式 ( Observer Pattern )