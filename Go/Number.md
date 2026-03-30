| Type     | Size            | Range                               |
| -------- | --------------- | ----------------------------------- |
| `int8`   | 8-bit           | -128 to 127                         |
| `int16`  | 16-bit          | -32,768 to 32,767                   |
| `int32`  | 32-bit          | -2.1B to 2.1B                       |
| `int64`  | 64-bit          | -9.2 quintillion to 9.2 quintillion |
| `uint8`  | 8-bit unsigned  | 0 to 255                            |
| `uint16` | 16-bit unsigned | 0 to 65,535                         |
| `uint32` | 32-bit unsigned | 0 to 4.3B                           |
| `uint64` | 64-bit unsigned | 0 to 18.4 quintillion               |
| `int`    | platform size   | 64-bit on modern systems            |
| `uint`   | platform size   | 64-bit on modern systems            |

### Float point error

IEEE 754
![[截圖 2026-03-30 下午2.43.16.png]]

you can't represent 0.1 exactly in binary
```
0.1 (decimal) → stored as exactly:
0.1000000000000000055511151231257827021181583404541015625
```