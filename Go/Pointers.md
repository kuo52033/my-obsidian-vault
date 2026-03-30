A pointer is a variable that stores the memory address of another variable, instead of the value itself.
```go
&x    // address-of  — gives you the pointer TO x
*p    // dereference — gives you the value AT the pointer

x := 100
p := &x // address
*p = 200 // * lets you SET the value through the pointer
fmt.Println(x) //200

Variable x                           Pointer p 
┌──────────────────┐            ┌────────────────────┐ 
│ value: 42        │◄─────────  │ value: 0xc000018030│ 
│ addr: 0xc...     │            │ addr: 0xc....b     │
└──────────────────┘            └────────────────────┘
```

### The zero value of a Pointer
```go
var p *int
fmt.Println(p) // <nil>
fmt.Println(*p) // panic: runtime error: invalid memory address
```

### With pointers - pass the address

Without pointers - pass by value(copy)
```go
func double(n *int) {
    *n = *n * 2   // modifies the ORIGINAL via its address
}

x := 10
double(&x)        // pass the address of x
fmt.Println(x)    // 20 ✅

main:  x = 10  (addr: 0xA)
         │
         │  pass address 0xA
         ▼
double: n = 0xA  ← pointer to original
       *n = 20   ← writes to 0xA directly, changes the original
```

---
### Pointers with structs ( most common use)
```go
type User struct {
    Name  string
    Email string
    Age   int
}

// ❌ Value receiver — operates on a COPY
func (u User) Increment() {
	u.Age++ // only changes the copy
}

// ✅ Pointer receiver — operates on the ORIGINAL
func (u *User) Increment() {
	u.Age++ // changes the real struct
}

// ❌ Pass by value — entire struct is COPIED
func updateAge(u User, age int) {
    u.Age = age   // modifies the copy only
}

// ✅ Pass by pointer — modifies the original
func updateAge(u *User, age int) {
    u.Age = age   // Go auto-dereferences struct pointers
}

user := User{Name: "Tim", Age: 27}
updateAge(&user, 28)
fmt.Println(user.Age)  // 28 ✅
```

> [!NOTE] 
> Go automatically dereferences struct pointers, so you don't need `(*u).Age = age`
