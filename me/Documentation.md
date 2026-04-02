### Situation
隨著產品功能增加、前後端工程師和 PM 之間的協作頻率提高，API 溝通問題越來越嚴重：

- API 規格散落在各處（Slack 對話、口頭溝通、程式碼註解），沒有統一的 source of truth
- 前端常因為不清楚 API 的 request/response 格式而反覆來回確認，影響開發效率
- API 變更時沒有通知機制，前端上線後才發現 contract 已經改了

### Task

建立一套集中式的 API 文件系統，讓所有人都能快速查到最新的 API 規格，減少溝通成本。

### Action

- 選擇 **GitBook** 作為文件平台，以專案為單位建立文件結構
- 為每個 API endpoint 建立標準化模板：HTTP method、URL、request body/query params、response schema、error codes、使用範例
- 制定規範：**後端開發新 API 或修改現有 API 時，必須同步更新 GitBook 文件**，作為 PR review 的 checklist 之一
- 與 PM、前端工程師同步，確保文件成為跨團隊的共同參考

### Result

- 前後端溝通效率明顯提升，API 相關的來回確認大幅減少
- 文件成為新人 onboarding 的重要資源，縮短了新進工程師上手時間
- API contract 有了明確的 source of truth，降低了因溝通落差導致的 bug