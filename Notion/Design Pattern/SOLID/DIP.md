---
notion-id: 3ac29bc8-eaf2-470c-b602-e91e19c00bec
---
### DIP( Dependency-Inversion Principle ) 依賴反向原則

> [!tip] 💡
> 高層次模組不應該直接依賴於低層次模組，兩者都依賴於 interface，高層次與低層次的解偶。
> ex: bad - 用 iphone 講電話 good - 用手機講電話

- 高層次模組: 要完成的商業目標所建立的
- 低層次模組: 要完成高層次模組所需的任務，比較細節的部份

## Bad

假如有個處理訂單模組，它使用 atm 模組來付款，這裡違反了 DIP (  高層次  OrderCheckout 依賴低層次 AtmPayment )，如果今天要新增信用卡，這邊會需要大改。

```javascript
// Bad 
class OrderCheckoutService{
    order: any
    constructor(order: any){
        this.order = order
    }

    execute(){
        const payment = new AtmPayment()  <-----!!! 這個依賴了 AtmPayment
        payemnt.execute(this.order)
    }
}
```

## Good

將低層次模組抽象個 interface ，並且低層次模組依賴並實作於此 interface

```javascript
interface IPayment{
    execute(order: any): void
}

class ATMPayment implements IPayment{
    execute(order: any){
        console.log('ATM pay')
    }
}
```

高層次模組依賴於 interface ( IPayment )，以後要新增付款方式，只要新增一個依賴於 IPayment 的低層次模組，高層次就可以直接使用。

```javascript
class OrderCheckoutService{
    order: any
    constructor(order: any){
        this.order = order
    }

    execute(payment: IPayment){
        payment.execute(this.order)
    }
}

const orderCheckoutService = new OrderCheckoutService('order')
orderCheckoutService.execute(new ATMPayment())
```

DI 依賴注入: 實現 DIP 的一個方式，將依賴的模組注入用 class construct or function param 代入

- 在設計時儘量可能分的出高層次與低層次的模組，就算是在同一層級。
- 高層次不要直接依賴低層次，而是依賴 Interface。
- 儘量使用 DI，但是要用 construct 或 function 的注入就要想一下，方向可以往，是不是只有這個 function 是特例需要，是的話就 function 參數注入。
