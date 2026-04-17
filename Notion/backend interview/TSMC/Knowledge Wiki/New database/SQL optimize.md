---
notion-id: 3385a6e2-1812-8073-a9b7-ccf69dd8d8bf
base: "[[New database.base]]"
多選: []
狀態: 進行中
---
Explain

| 欄位 |   |
| --- | --- |
| `type` | 掃描方式，從好到壞：const > ref > range > index > ALL |
| `key` | 實際用了哪個索引，NULL 代表沒用索引 |
| `rows` | 預估掃描幾筆，越少越好 |
| `Extra` | `Using index`（覆蓋索引）好，`Using filesort`、`Using temporary` 要注意 |

## 索引

