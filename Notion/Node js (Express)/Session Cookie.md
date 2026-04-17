---
notion-id: 42ca6884-4a60-4efb-bf84-e015ee30e379
---
## Session 為一種機制，讓從瀏覽器發出的 request 變成 stateful，server 才能與 client 產生連結，有兩種方法可實作 Session，第一為網址，第二為 Cookie，Cookie 為儲存在瀏覽器的資訊。

## 存在 Cookie 中的資料有可能被竄改，有兩種方法解決，第一是Cookie-based session，將 Cookie 中的資料做加密在儲存；另一個是把資料存在 Server 端，而 Cookie 裡面只存一個 SessionID，每次 request 都會帶著這個 SessionID，並跟 Server 做對應。

## Session 容易受 CSRF Attack(跨網域請求偽造攻擊)

# Token

## Token 為一串亂碼，當 Server 收到 Token時，會去資料庫比對，然後抓取相對應的使用者資料來使用。

# Json Web Token (JWT)

## 使用傳統 Token 時如果使用者一多，會造成資料庫伺服器負荷不堪，JWT 則是直接把使用者資訊記在 Token 中，省去了資料庫查詢的開銷。JWT 分為三個部分，標頭( Header) 內容( Payload) 簽名( Signature)。

### ==Header==

### 包含加密類型( alg )以及定義類型( typ )

```javascript
{
  "alg": "HS256",
  "typ": "JWT"
}
```

### ==Payload==

### 可以在這邊放使用者暱稱，帳號等等，因為這些資料尚未被加密，因此不推薦放置私密資料。

```javascript
{
  "sub": "1234567890",
  "name": "John Doe",
  "admin": true
}
```

### ==Signature==

### 最後需要一組密碼來做加密，來防止有人來竄改 JWT ，而密碼只有伺服器端知道。這部分由上面兩個經由 Base64 以 . 符號組合起，並經由密碼加密( 範例為 "secret")。

```javascript
HMACSHA256(base64UrlEncode(header) + "." + base64UrlEncode(payload), "secret")
```

## 最後將三個部分組成便成為 JWT。每次會透過 decode 簽名與前面的部分來做比較，如果相同代表驗證正確，會再呼叫其他函式。

## JWT 可以跨越不同 Server，因為它是將資料存在 Token 中，因此 Server 只要有相同的 Secret Key 就可以對相同的 Token 做 decode，但是傳統的 Session 是存在 Server 的資料庫中，因此資料在不同的 Server 都必須要有。