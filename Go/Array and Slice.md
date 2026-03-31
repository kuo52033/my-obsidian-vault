### Array
```go
var arr [5]int              // size is FIXED, part of the type
arr := [3]int{1, 2, 3}     // literal
arr := [...]int{1, 2, 3}   // compiler counts the size for you
```

Array are rarely used directly in Go. They exists mainly as ==backing storage== for slice

---

### Slice

A slice is not an array. Is is a 3-fields that describes a window into an array.

```go
type slice struct {
    ptr *T   // pointer to underlying array
    len int  // number of elements you can see
    cap int  // total space available from ptr onward
}

// Creating slice
s := []int{1, 2, 3, 4, 5}
s := make([]int, 3, 10) // len=3, cap=10 — preallocate space
s := arr[1:4] // Slicing an array or slice
var s []int // nil slice

Slice header (on stack):          Underlying array (on heap):
┌─────────────────┐               ┌───┬───┬───┬───┬───┐
│ ptr: 0xAAA      │──────────────►│ 1 │ 2 │ 3 │ 4 │ 5 │
│ len: 5          │               └───┴───┴───┴───┴───┘
│ cap: 5          │               0xAAA
└─────────────────┘
```

### Slices share the underlying array

```go
arr := [5]int{1, 2, 3, 4, 5}
s1 := arr[0:3] // [1, 2, 3]
s2 := arr[1:4] // [2, 3, 4]

s1[1] = 99 // modifies the shared array!

fmt.Println(s1) // [1 99 3] 
fmt.Println(s2) // [99 3 4] ← s2 sees the change! 
fmt.Println(arr) // [1 99 3 4 5] ← original changed too!

```

### Append

```go
s := make([]int, 3, 5) // len=3, cap=5
s = append(s, 10) // len=4, cap=5 - fit
s = append(s, 20) // len=5, cap=5 - fit
s = append(s, 30) // len=6, cap= - OVERFLOW! new array created

new array: 
┌───┬───┬───┬───┬───┬───┬───┬───┬───┬───┐ 
│ 0 │ 0 │ 0 │ 10│ 20│ 30│   │   │   │   │ └───┴───┴───┴───┴───┴───┴───┴───┴───┴───┘ 
cap doubles (roughly) → 10 s now points to NEW array — old array is abandoned
```

### nil slice vs. empty slice
```go
var s1 []int        // nil slice
s2 := []int{}       // empty slice
s3 := make([]int,0) // empty slice

nil slice:
┌──────┬─────┬─────┐
│ nil  │  0  │  0  │  ptr is nil
└──────┴─────┴─────┘

empty slice:
┌──────┬─────┬─────┐
│ 0xZZ │  0  │  0  │  ptr points somewhere, but len=0
└──────┴─────┴─────┘

// BUT both behave the same for append and len
```

### Copy

When you want an independent slice with no shared memory
```go
src := []int{1, 2, 3, 4, 5} 
dst := make([]int, len(src))

copy(dst, src) // copies element, not the pointer
```

### Slice of slice - 2D

```go
matrix := [][]int{
	{1, 2, 3},
	{4, 5, 6},
	{7, 8, 9},
}

// Each row is an independent slice
matrix header 
┌──────┬───┬───┐ 
│ ptr  │ 3 │ 3 │ 
└──────┴───┴───┘ 
│ 
├──► row0 header ──► ┌───┬───┬───┐ 
│                    │ 1 │ 2 │ 3 │ 
├──► row1 header ──► ┌───┬───┬───┐ 
│                    │ 4 │ 5 │ 6 │ 
└──► row2 header ──► ┌───┬───┬───┐ 
                     │ 7 │ 8 │ 9 │
```

### Performance Tips

Pre-allocate with `make` when size is known
```go
// ❌ grows multiple times, multiple allocations
s := []int{}
for i := 0; i < 10000; i++ {
    s = append(s, i)
}

// ✅ allocates once
s := make([]int, 0, 10000)
for i := 0; i < 10000; i++ {
    s = append(s, i)
}
```

Passing slices to functions — no copy of data
```go
// Only the 3-field header is copied (24 bytes) 
// The underlying array is SHARED 
func process(s []int) { 
	s[0] = 99 // ✅ modifies the original array 
	s = append(s, 100) // ⚠️ if this causes growth,  caller won't see the new element! 
}
```