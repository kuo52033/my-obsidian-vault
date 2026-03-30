A pointer is a variable that stores the memory address of another variable, instead of the value itself.
```go
&x    // address-of  — gives you the pointer TO x
*p    // dereference — gives you the value AT the pointer

x := 100
p := &x // address
*p = 200 // * lets you SET the value through the pointer
fmt.Println(x) //200
```