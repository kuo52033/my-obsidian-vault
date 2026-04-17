---
notion-id: 3385a6e2-1812-804a-b150-dea0735de9b4
base: "[[New database.base]]"
指派: []
狀態: 完成
---
團隊原本只有對共用 library 寫 unit test，主要業務功能幾乎沒有測試覆蓋。隨著功能越來越多，問題開始浮現，改 A 壞 B、edge case 漏網，每次上線都很沒把握，要靠人工確認才敢部署。
所以我在新專案建立了完整的測試流程。unit test 確保單一函式的邏輯正確性，外部依賴用 mock 隔離，跑得快，每次 push 都會執行。integration test 則是模擬完整的業務處理流程，連真實的測試 DB，驗證從 API 到資料層的整體正確性，確保各模組串起來的行為符合預期。
框架用 Jest，並在 CI pipeline 加入 quality gate，測試沒過或覆蓋率低於門檻就擋住，不讓有問題的程式碼進到 production。
導入之後系統穩定度明顯提升，bug 回報率下降，部署也從原本像在拆炸彈，變成有測試保護的信心部署。