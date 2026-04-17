---
notion-id: a4a99912-4e0f-4015-aa37-95712d3af993
---
### Worker thread

nodeJS 在處理 I/Ｏ operation 上有 event loop 處理，但在一些運算很重的 operation上會把主執行緒卡住，因此 nodeJS 提供 worker thread 來處理這些 CPU intensive 的任務，他會建立另外的 thread，讓你的程式可以平行運作。

### Child Process

Child Process 會直接建立一個新的 nodeJs instance(process)，有獨立的記憶體，彼此世隔離的，因此要溝通需要透過 IPC(inter-process communication)。

- 增加隔離性、multi-core system、child process 壞了不會影響到main process

### V8 Engine

v8 引擎是一個由 google 開發的開源 javascript 引擎，他會在 javascript 執行時動態的將程式碼轉換為機器碼，屬於直譯語言，但他跟其他語言不一樣，使用了即時編譯的技術，分析、紀錄執行的程式碼，使其速度加快，因此 nodeJS 在server 端也使用 v8 引擎。

### Event Loop

event loop 是一個機制讓 nodeJS 能夠執行 non-blocking I/O operation，是藉由 libuv 來完成的，libuv 封裝了不同平台的 I/O 操作，以及非同步 API，這些系統 kernel 的 I/O 操作會是多執行緒，然後在背景處理，當任務完成後再告訴 nodeJS ，callback 可以放置適當的 queue 裡， event loop 會有順序的去檢查並同步執行。

### Callback

callback 就是一種函式，他可以當作參數帶進去到別的函式，作用是可以照順序的執行，可以用在同步及非同步，像是非同步的 setTimeout 第一個參數是一個函式，第二個參數為毫秒，那他會等到時間到了把 callback 放去 queue 裡讓 event loop 判斷可否執行。

### Event Emitter

他本身與 event loop 無關，是讓你在 application 中創造 event driven 的工具，利用 on 來註冊一個事件，emit 來觸發事件，他本身在執行事件會是同步的。

