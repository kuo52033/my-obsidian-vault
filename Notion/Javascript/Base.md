---
notion-id: c6b665e6-5ca9-40a8-a0a4-b51b5e8d520f
---
## By value: 建立數字、字串、布林等等 primitive type 時，會在記憶體中建立一個自己的位置，因此如果把一個 b 指定到 a 時(b = a)，b也會建立一個自己的記憶體空間，彼此部會受到干擾。

## By reference:  當在建立 Array、Object、funciton 時，依樣會在記憶體中建立自己的位置，但如果有一個 b 指定到 a 時，不會在額外建立記憶體空間，而是都只到同一個位置，因此如果更改 a 時 b 也會發生改變。

### 例外: 如果是用 Object literal 的方式指定物件的話( a = { ... } )，則會變成 by value 再新增一個記憶體位置。

# 物件傳參考

```javascript
function fn(item) {
  const newItem = {
    name: "小郭",
  };

  item = newItem;
}
const person = {
  name: "小明",
};
fn(person);
console.log(person); //name: "小明"
```

![[1png.png]]

## person 指向0x001，進入 fn 後創建兩個 item 以及 newitem，一開始 item 指向0x001，執行 item = newitem 後 item 變指向0x002，因此 person 依舊還是小明。

 

## 如果要改 person 值的話，可以用 item.name = newitem.name，如果屬性很多的話，可以使用下列函式。

```javascript
Object.keys(item).forEach((key) => {
  item[key] = newItem[key];
});
```

## for ... in 以及 for ... of 差異

### for .. in 輸出的為 key 的名稱，因此用在物件上，而 for ... of 輸出的為值，因此用在陣列。 如果 for ... of 要用在物件上的話，必須搭配 Object.keys 來使用。

```javascript
var a = { name: "a", age: 28, married: false };
for (let i of Object.keys(a)) {
  console.log(`${i} ${a[i]}`);
}
```