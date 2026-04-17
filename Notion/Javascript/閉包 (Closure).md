---
notion-id: 0b970eda-5b89-4684-8968-9362ba11d3b6
---
## 閉包 (Closure) 是一種函式，它能夠存取被宣告當下的環境中的變數。

## 在JavaScript中，即使在外層區塊已經回傳的狀況下，只要內層區塊還保留著一份參考，那麽外層區塊的環境不會隨著回傳而消失，我們依然可以存取外層環境中的變數。

## 函式內的函式取用外層作用域的變數，可以擁有私有變數。

```javascript
const countMoney = (first) => {
  let money = first;
  return (buyMoney) => {
    money = money - buyMoney;
    return money;
  };
};
let timmoney = countMoney(2000);
console.log(timmoney(100)); //1900
console.log(timmoney(200)); //1700
console.log(timmoney(300)); //1400

let jerrymoney = countMoney(500);
console.log(jerrymoney(200)); //300
console.log(jerrymoney(50)); //250
```

## 將 countMoney 裡回傳的函式儲存至 timmoney 以及 jerrymoney，兩個 money 為私有變數且互不干擾，每執行一次函式則回傳扣除後的金額，也會更新該私有變數。They share the same function body definition, but store different lexical environments。

## 每當函式被呼叫時，都會產生一組新的語彙環境 (Lexical Environment)。