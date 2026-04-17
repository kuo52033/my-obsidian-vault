---
notion-id: 46106988-3d6f-41d4-a828-5024ec6e469e
---
## 1. let 的作用域在 block {} ，而 var 的作用域只在function ，var 可以重複定義而 let 無法。

## 2. undefined 為有宣告變數但是沒給與值， not defined 為連變數宣告都沒有。

## 3.函示宣告(function ...() {} ) 有提升的作用，可以在宣告他之前使用他，但是使用函式運算式( const ... = () ⇒ {} ) 無法在宣告前使用。

## 4. hoisting : var 變數如果還沒宣告就使用她，回出現undefined，也就是變數的宣告會被提升，但是賦值不會提升。

```javascript
console.log(a); //undefined
var a = 5;
```

## 5.暫時死區(Temporal Dead Zone，TDZ): let 以及 const 如果在宣告變數前使用的話，會出現 ReferenceError，也就是暫時死區無法使用。

```javascript
const fun = (a) => {
  console.log(a); //5
  var a = 1;
	console.log(a); // 1
};
fun(5);
```

```javascript
const fun = () => {
  console.log(a); //ReferenceError: Cannot access 'a' before initialization
  let a = 1;
};
fun();
```