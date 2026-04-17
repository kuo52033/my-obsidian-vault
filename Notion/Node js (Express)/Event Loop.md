---
notion-id: 14dedcf1-b831-464a-b916-774fd0024c05
---
The event loop is what allows Node.js to perform non-blocking I/O operations

the Event Loop executes the JavaScript callbacks registered for events, and is also responsible for fulfilling non-blocking asynchronous requests like network I/O

「Node.js 之所以高效，是因為採取單執行緒與 Event Loop 的概念；將所有需要等待結果、請求外部資源的函式，全部丟到 Event Loop 中等待；而 Event Loop 的邏輯是 Node.js 底層用 C 語言撰寫的 libuv 庫來運行的。」

![[螢幕擷取畫面_2024-03-03_161519.png]]

每個 phase 都是 queue 結構

Event loop executes tasks in `**process.nextTick queue**` first, and then executes `**promises microtask queue**`, and then executes `**macrotask queue**`.

`**process.nextTick queue**`**、**`**promises microtask queue**`** 不由 libuv 的 event loop 管理，屬於 V8**



當該 phase 的任務被消耗完或 callback limit 到達了，event loop 就會往下一個 phase 

- timers: `setTimeout()` and `setInterval()`  的 callbacks
- pending callbacks: system operations such as types of TCP errors
- idle, prepare: 內部使用
- poll: 執行 I/O callbacks，如果 queue 為空且有設置 `setImmedidate()` ，進入 check 階段。如果 queue 為空且沒設置`setImmedidate()` ，維持在 poll 階段直到 timers 有時間到。
- check: 執行 `setImmedidate()`
- close callbacks: 一些關閉的回呼函數，如：`socket.on('close', ...)`

```javascript

setTimeout(() => {
  console.log('timeout');
}, 0);
setImmediate(() => {
  console.log('immediate');
});
```

兩個不一定誰會先執行，看當下環境執行速度

```javascript
const fs = require('node:fs');
fs.readFile(__filename, () => {
  setTimeout(() => {
    console.log('timeout');
  }, 0);
  setImmediate(() => {
    console.log('immediate');
  });
});
```

immediate 必定先執行，因為 readFile 執行完會在 poll 階段，下個為 check 階段可直接執行 immediate

process.nextTick(): 一個特殊的非同步API，不屬於 event loop 階段，處於第一順位。

![[螢幕擷取畫面_2024-06-08_163807.png]]

> [!tip] 💡
> Node.js has two types of threads: one Event Loop and `**k**` Workers. The Event Loop is responsible for JavaScript callbacks and non-blocking I/O (network I/O), and a Worker executes tasks corresponding to C++ code that completes an asynchronous request, including blocking I/O (file I/O、DNS lookup) and CPU-intensive work.

> [!tip] 💡
> Don’t use CPU-intensive modules/utils/function

- JSON.parse、stringify
- Regexp
- Crypto
- Zlib
- FS

執行JS的主執行緒跟執行 event loop 的執行緒是同一個