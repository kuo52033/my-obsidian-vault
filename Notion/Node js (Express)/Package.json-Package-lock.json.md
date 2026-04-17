---
notion-id: 2c43556d-bad8-4877-8948-af4b01534213
---
### Package-lock.json

package-lock.json 會在 npm install 時生成，他記錄了當下安裝的各個 package 以及底下的 dependency 的來源及版本號，是一個 versioned dependency tree，為了讓每個開發者可以統一 dependency 

### 應該被 commit 到 repository 原因

- 保證每位開發者安裝的 dependency 版本都一致
- 保證在測試環境及正式環境安裝版本一致
- 能夠更明確 version tree 的差異
- 加速 npm 安裝速度，跳過重複安裝的 package

將每個版本都鎖定是不好的，因為能鎖定的只有 package.json 裡的第一層套件，底下的 dependency 是沒辦法鎖定版本的，如果裡面的套件升級了，會造成問題，因此 Package-lock.json 也能解決此問題。

- [https://docs.npmjs.com/cli/v10/configuring-npm/package-lock-json](https://docs.npmjs.com/cli/v10/configuring-npm/package-lock-json)
- [Should I add package-lock.json to git? Why is it important to commit `package-lock.json` into git?](https://medium.com/@InspireTech/should-i-add-package-lock-json-to-git-why-is-it-important-to-commit-package-lock-json-into-git-e8273a8aad00)


