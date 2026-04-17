---
notion-id: 3385a6e2-1812-80e8-ba64-f11a47afab0e
base: "[[New database.base]]"
指派: []
狀態: 完成
---
我們的架構是 Cloudflare → NLB → NGINX Ingress。取得真實 Client IP 的方式是透過 HTTP 層的 X-Forwarded-For header，Cloudflare 會在 header 裡帶上真實用戶 IP，NGINX 設定 `use-forwarded-headers: true` 來讀取這個 header。

為了防止 X-Forwarded-For 被偽造，我們在 NGINX 的 `proxy-real-ip-cidr` 設定只信任 Cloudflare 的 IP ranges，這樣只有真正從 Cloudflare 過來的請求，NGINX 才會相信它帶的 header，確保 rate limiting 和 access log 拿到的是真實 IP。

另一種做法是使用 Proxy Protocol。NLB 在 TCP 層的封包開頭插入一段 Proxy Protocol header，裡面帶有真實 Client IP，NGINX 設定 `use-proxy-protocol: true` 來讀取。

好處是這個資訊在 TCP 層傳遞，應用層完全無法偽造，所以不需要依賴信任特定 CIDR 來保證安全性。代價是 NLB 和 NGINX 兩端都要同時開啟，設定上要一起異動。

| use-proxy-protocol | false |  true |
| --- | --- | --- |
| IP 來源 | X-Forwarded-For header | Proxy Protocol TCP 層 |
| 可以被偽造 | ✅ 可以 | ❌ 不行 |
| NLB 需要改 | 不需要 | 要開 Proxy Protocol v2 |
| proxy-real-ip-cidr | 需要限制 Cloudflare IP | 不需要，TCP 層天然安全 |
| use-forwarded-headers | 需要 true | 可以不需要 |