### Explicit assignment
```go
var name string = "Tim"
var age  int    = 27
var isActive bool = true
var count int        // 0
var name  string     // ""
var err   error      // nil

var handler http.Handler = &MyHandler{}
```

Using explicit when declaring a value without an initial value. Declaring interface or specific type you want to enforce

---
### Implicit assignment
```go
name     := "Tim"
age      := 27
isActive := true
```

Using implicit when the type is obvious from the value