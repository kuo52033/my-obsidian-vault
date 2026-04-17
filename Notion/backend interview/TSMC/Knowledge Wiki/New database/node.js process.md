---
notion-id: 3385a6e2-1812-8070-b7d2-ea22649fcf60
base: "[[New database.base]]"
多選: []
狀態: 完成
---
```json
Node.js Process
│
├── V8 Engine
│     ├── Heap（heapUsed / heapTotal）
│     │     └── JS 物件、變數、函式、closure
│     │
│     └── Call Stack
│           └── 目前正在執行的函式呼叫鏈
│
├── libuv
│     ├── Event Loop  ← 執行機制，不是記憶體
│     │     └── 各個 phase（timers, I/O, check...）
│     │
│     └── Thread Pool（4 條）
│           └── 處理 blocking I/O（fs, crypto, dns）
│
└── external（process.memoryUsage().external）
      └── Buffer、C++ 物件佔用的記憶體
```