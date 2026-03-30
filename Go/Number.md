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

```go
sum := 0.0 
for i := 0; i < 10; i++ { 
	sum += 0.1 
} 
fmt.Println(sum) // 0.9999999999999999 ← not 1.0! 
fmt.Println(sum == 1.0) // false

fmt.Println(0.1 + 0.2) // 0.30000000000000004 
fmt.Println(0.1 + 0.2 == 0.3) // false ⚠️
```

> For money, inventory counts, or any exact calculation — use integers or a decimal library.