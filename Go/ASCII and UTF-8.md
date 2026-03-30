| Encoding | Coverage                                    | Size               |
| -------- | ------------------------------------------- | ------------------ |
| ASCII    | 128 characters (English only)               | 1 byte per char    |
| UTF-8    | 1,114,112 characters (all languages, emoji) | 1–4 bytes per char |
UTF-8 is a **superset of ASCII** — the first 128 UTF-8 characters are identical to ASCII.

---

```go
var a byte = "a"  // byte = ASCII
var b rune = "他" // rune = UTF-8
```
---
## problem

```go
s := "Hello, 世界"

fmt.Println(len(s)) // ❌ 13 — counts BYTES, not characters 
fmt.Println(len([]rune(s))) // ✅ 9 — counts actual characters
```

### Iterating

```go

s := "Hello, 世界" 

// ❌ Iterating by BYTE — breaks multi-byte characters 
for i := 0; i < len(s); i++ { 
	fmt.Printf("%c ", s[i]) // garbled output for 世界 
} 

// ✅ Iterating by RUNE — correct Unicode handling 
for i, ch := range s { 
	fmt.Printf("index:%d char:%c\n", i, ch) 
}
```

> `for range` on a string automatically decodes UTF-8 and gives you **runes**, not bytes.
> The golden rule: **use `rune` when you care about characters, `byte` when you care about raw data.**
