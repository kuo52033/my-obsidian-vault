---
notion-id: 39ea85bc-2a38-4c56-9bd5-4007d111c7c0
---
```javascript
let obj = {
  website: "pjchender",
  country: "Taiwan"
}

let {website:wb, country:ct} = obj;
console.log(wb);  // pjchender
console.log(ct);  // Taiwan
```

### 物件的解構附值強調的是屬性名稱要正確，也可以經過 : 來更改變數名稱，因此 let { website:wb, country:ct } 冒號前面為正確屬性的名稱，但值是給冒號之後的變數。