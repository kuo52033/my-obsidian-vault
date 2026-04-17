---
notion-id: 6375a467-577a-4503-80d8-5b71c9f64547
---
collect all remaining arguments into an autual array

```javascript
function tim(first, second, ...rest){
	console.log(first)
	console.log(second)
	console.log(rest)
}

tim(1, 2, 3, 4, 5) //1 2 [3, 4, 5]
```