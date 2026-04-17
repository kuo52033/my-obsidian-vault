---
notion-id: 58b092ba-c240-443d-abd8-946bd2ab2505
---
## Middlewre(中介軟體)

### 用來接受從客戶端傳的 request 到回傳 response 之間所處理的事件，針對接收到 request 的進行解析處理，處理完畢後在決定是否傳給下一個 middleware 或中斷傳遞。

```javascript
var express = require("express");
var app = express();

app.use(...middleware);
```

## Node JS

- Node is a Javascript runtime environment that executes code outside of the browser
- A Node.js app runs in a single process, without creating a new thread for every request (single thread)
- When Node.js performs an I/O operation, like reading from the network, accessing a database or the filesystem, instead of blocking the thread and wasting CPU cycles waiting, Node.js will resume the operations when the response comes back
- module.export default to be an empty object{}
- NPM ( Node Package Manager ) : A library oof thousands of packages published by other developers that we can use for free，easily install and manage in node projects.
- (npm init) is a way of making package.json file，which include the metadata and the dependencies you install. (npm init -y) : to skip the question
- node application are asynchronous by default，a single thread to handle all requests (non-blocking I/O D model

Node程式裡的相對路徑代表的是執行node時所在的相對路徑，而不是js檔本身的相對路徑。

- __dirname : 回傳被執行js 檔所在資料夾的絕對路徑。
- __filename : 回傳被執行js 檔的絕對路徑。
- Process.cwd() : 回傳執行node 指令所以資料夾的絕對路徑。

使用require來引進js 檔時可使用相對路徑，效果相當於__dirname，不會因啟動node 時的資料夾不同而發生錯誤。

