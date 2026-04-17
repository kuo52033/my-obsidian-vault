---
notion-id: 2e95a6e2-1812-8015-b903-fd1212184faf
base: "[[New database.base]]"
指派: []
狀態: 完成
---
### Situation

專案的 CI/CD pipeline（Jenkins → Docker Build → Push to ECR → Deploy to EKS）平均建置時間長達 **15 分鐘**，其中 Docker build 階段是最大瓶頸。分析後發現幾個核心問題：

1. **Docker 快取頻繁失效**：Dockerfile 中 `COPY . .` 放在 `npm install` 之前，任何程式碼變更都會使依賴安裝的快取層失效，導致每次建置都重跑 `npm install`
2. **依賴版本不一致**：`package-lock.json` 未納入版控（被放在 `.gitignore`），CI 和本地環境的依賴版本可能不同，偶爾出現「我電腦可以跑」的問題
3. **映像檔體積過大**：單階段建構，把所有原始碼、開發工具都打包進最終映像檔，造成不必要的體積膨脹和攻擊面擴大

### Task

由我主導 Docker build 流程的優化，目標是大幅縮短建置時間、確保建置的確定性和可重現性，並減少映像檔體積。

### Action

**1. 建立依賴一致性 — 納管 **`**package-lock.json**`

- 將 `package-lock.json` 從 `.gitignore` 移除並提交至版控
- 這是所有優化的基石，確保依賴樹完全鎖定，保證任何環境下建置結果一致

**2. 優化 Docker 分層快取策略**

- 調整 Dockerfile 指令順序：先 `COPY package.json package-lock.json` → 再 `RUN npm ci` → 最後才 `COPY . .`
- 這樣只有 `package.json` 變更時才會重裝依賴，一般程式碼修改可以直接命中快取，跳過最耗時的 `npm ci` 步驟

**3. 啟用 BuildKit + 進階快取掛載 (docker 18.09後推出的)**

- 啟用 `DOCKER_BUILDKIT=1` 並在 Dockerfile 頂部加入 `#syntax=docker/dockerfile:1`
- 為 `npm ci` 設定 `-mount=type=cache,target=/root/.npm`，持久化 npm 套件快取
- 為 `npm run build` 設定 `-mount=type=cache,target=/src/node_modules/.cache`，持久化前端打包工具快取
- 即使快取層完全失效的「冷啟動」情境，也能因為本地有 npm cache 而大幅加速

**4. 導入 Multi-stage Build + 白名單式 COPY**

- 將 Dockerfile 分為 `builder` 階段（安裝依賴、編譯）和 `production` 階段（僅包含運行時檔案）
- 最終階段採用逐項 `COPY --from=builder` 的白名單模式，只複製 `node_modules`、`server`、`config`、`migrations` 等必要目錄
- 開發依賴、原始碼、`.git` 等不會進入最終映像檔

**5. 將 **`**npm install**`** 替換為 **`**npm ci**`

- `npm ci` 嚴格依照 `package-lock.json` 安裝，速度更快且確保確定性建置
- 搭配 `npm prune --production` 在 builder 階段最後移除 devDependencies

### Result

- 建置時間從 **15 分鐘縮短至 6~7 分鐘**，**縮短超過 50%**
- 達成 **100% 可重現**的確定性建置，消除了環境差異導致的 build failure
- 映像檔體積**顯著縮小**（只包含 production 運行時所需檔案）
- 建立了現代化、可維護的 Docker 建置標準，後續其他專案可快速套用
