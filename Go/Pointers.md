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
> - Go automatically dereferences struct pointers, so you don't need `(*u).Age = age`
> - if ANY method uses \*T, make them ALL \*T

### Optional fields (pointer=nullable)
```go
// value types **always have a value** — they cannot be "absent":

type UserProfile struct {
    Name     string
    Email    string    // always has a value - "" if not set
    Phone    *string   // nil means "not provided"
    Age      *int      // nil means "not provided"
}

phone := "+886-912-345-678"
profile := UserProfile{
    Name:  "Tim",
    Phone: &phone,     // has value
    Age:   nil,        // not provided
}

if profile.Age != nil {
    fmt.Println(*profile.Age)
}
```

### Passing large structs efficiently
```go
// ❌ Copies the entire Order struct on every call 
func processOrder(o Order) { ... } 
// ✅ Passes only the pointer (8 bytes on 64-bit) 
func processOrder(o *Order) { ... }
```

### Interface
```go
type Animal interface { 
	Speak() string 
}

type Dog struct{ 
	Name string 
}

// pointer receiver
func (d *Dog) Speak() string {
	return "Woof!"
}

var a Animal = Dog{Name: "Rex"} // ❌ compile error 
var a Animal = &Dog{Name: "Rex"} // ✅
d := Dog{}
d.Speak() // ✅ Go silently does (&d).Speak()
```

---
### Common Mistakes

1. Unnecessary pointer to small types
```go
// ❌ Unnecessary — int is tiny, pointer adds overhead
func add(a, b *int) *int {
    result := *a + *b
    return &result
}

// ✅ Just use values for primitives
func add(a, b int) int {
    return a + b
}
```
2. 