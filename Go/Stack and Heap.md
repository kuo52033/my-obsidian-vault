Go use two memory regions simultaneously.
```
RAM
┌─────────────────────────────────────────────────────┐
│                                                     │
│   ┌─────────────────┐    ┌─────────────────────┐   │
│   │      STACK      │    │        HEAP          │   │
│   │                 │    │                      │   │
│   │ • Fixed per     │    │ • Large, shared      │   │
│   │   goroutine     │    │ • GC managed         │   │
│   │ • Fast          │    │ • Slower             │   │
│   │ • Auto freed    │    │ • Manual via GC      │   │
│   │ • LIFO order    │    │ • Any order          │   │
│   └─────────────────┘    └─────────────────────┘   │
│                                                     │
└─────────────────────────────────────────────────────┘
```
### Stack

**LIFO (Last In First Out)** memory region. Each goroutine gets its own stack. It grows and shrinks automatically as functions are called and return.

```go
func main() { 
	x := 10 // lives on stack 
	result := add(x) // call — stack grows 
	fmt.Println(result) 
	} // return — stack shrinks 

func add(n int) int { 
	y := n + 1 // lives on stack 
	return y 
} // return — y is gone

```
==**Freeing stack memory is instant** — just moving the stack pointer back up. No GC involved.==

---
### Heap

The heap is a **large shared memory pool** where data lives beyond a single function's lifetime. The **Garbage Collector (GC)** manages it.

```go
func newUser() *User { 
	u := User{
		Name: "Tim", 
		Age: 27
	} // must survive after function returns 
	return &u // escapes to heap 
} 

func main() { 
	user := newUser() // user points to heap memory 
	fmt.Println(user.Name) 
}

Stack:                               Heap: 
┌──────────────────┐                 ┌───────────────────────┐ 
│ main frame       │                 │                       │ 
│ user: 0xC000  ───┼───────────────► │ User {                │ └──────────────────┘                 │     Name: "Tim" 0xC000│ 
                                     │     Age: 27           │ 
	                                 │    }                  │                                           └───────────────────────┘
```

The Go **compiler** decides automatically at compile time using **escape analysis**. You never manually allocate/free like C.


> [!Note] 
>    Variable's address used OUTSIDE its function? → HEAP 
Variable stays INSIDE its function? → STACK

---
### Goroutine

Every goroutine has its own **independent stack**. They don't share stacks, check[[Goroutine]]

---

### Garbage Collector — Heap Cleanup

The GC runs in the background and frees *heap memory* that's no longer reachable.

```
GC starts from ROOTS: 
- Global variables 
- Stack variables (all goroutine stacks) 
- CPU registers 
  
Then TRACES all pointers from roots: 

Stack:                          Heap: 
┌──────────────┐              ┌──────────────────────────────┐ 
│ user: 0xC000 │──────►       │ User{Name:"Tim"} ← REACHABLE │ 
│ temp: 0xD000 │──────►       │ Temp{} ← REACHABLE           │ └──────────────┘              │                              │ 
                              │ OldUser{} ← UNREACHABLE      │ 
                              │ (no pointer to it)           │ 
                              │ ← GC frees this              │                                    └──────────────────────────────┘
```

---
### Performance Implications 

Stack allocation: move stack pointer — nanoseconds 
Heap allocation: GC overhead, fragmentation — slower Stack 
access: CPU cache friendly (compact, sequential) 
Heap access: scattered, more cache misses