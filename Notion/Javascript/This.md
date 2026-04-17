---
notion-id: 8f8dc751-7e2d-4cd7-a7a1-d68dca943fa8
---
## this 重點在於被哪個物件下呼叫，不關在哪裡宣告。

```javascript
function callName() {
  console.log(this.name);
}

var name = "global";
var fun = {
  name: "local",
  call: callName,
};

callName(); //global
fun.call(); //local
mycall = fun.call;
mycall(); //global
```

## this 在函式外的全域環境下，都會被當作全域物件，在瀏覽器下為 window，node 下為global，在嚴格模式下 this 的值會是undefined。this 在函式內則取決於函式如何被呼叫。

## ES5 導入了 Function.prototype.bind 方法，呼叫 fun.bind(object) 後，無論如何呼叫，原始 function 永遠與 object 綁定在一起，無法對同一個 function bind 兩次。

# 可以把 a.b.c.hello() 看成 a.b.c.hello.call(a.b.c)，以此類推，就能輕鬆找出 this 的值