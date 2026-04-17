---
notion-id: 8158e52d-65b0-4036-aa7c-b41f8c2efb33
---
> [!tip] 💡
> "I/O" refers primarily to interaction with the system's disk and network supported by [libuv](https://libuv.org/).

libuv is a multi-platform support library with a focus on asynchronous I/O.

如果使用 libuv 或一些原生模組中的同步方法常會造成 blocking， 所以 I/O 操作要使用非同步的版本，才能 non-blocking 

- 同步（synchronous）代表執行時程式會卡在那一行，直到有結果為止，例如說`readFileSync`，要等檔案讀取完畢才能執行下一行
- 非同步（asynchronous）代表執行時不會卡住，但執行結果不會放在回傳值，而是需要透過回呼函式（callback function）來接收結果

 **synchronous** file read (blocking)

```javascript
const fs = require('node:fs');
const data = fs.readFileSync('/file.md'); // blocks here until file is read
```

**asynchronous ****file read (non-blocking)**

```javascript
const fs = require('node:fs');
fs.readFile('/file.md', (err, data) => {
  if (err) throw err;
});

const util = require('util');
// Convert fs.readFile into Promise version of same    
const readFile = util.promisify(fs.readFile);
```

callback 太多會造成程式碼複雜(callback hell)，Promises (ES6) and Async/Await (ES2017) 用來解決這個問題，執行非同步程式不需要 callback