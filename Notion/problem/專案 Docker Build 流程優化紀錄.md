---
notion-id: 2875a6e2-1812-8061-abdc-cae8f7b4f003
---
- **日期:** 2025年10月9日
- **目標:** 解決 Docker 映像檔建置流程中存在的速度慢、可靠性低、映像檔體積過大等問題。

---

### 1. 成果摘要

本次優化成功將專案 CI/CD 的平均建置時間從 **15 分鐘**大幅縮短至 **6-7 分鐘**，顯著提升了開發與部署效率。核心成果包括：

- **建置速度提升超過 50%**。
- 確保了**100% 可重現**的確定性建置。
- 顯著**減少了生產環境映像檔的體積**與安全風險。
- 建立了現代化、可維護的 Docker 建置標準流程。

---

### 2. 背景與痛點

優化前的 Dockerfile 及建置流程存在以下主要問題：

- **緩慢的建置速度**：由於 `COPY . .` 指令導致 Docker 快取頻繁失效，最耗時的 `npm install` 步驟在每次建置中幾乎都會重複執行。
- **不一致的開發環境**：未將 `package-lock.json` 納入版本控制，導致不同開發者和 CI 伺服器上的依賴版本可能存在差異，引發「在我電腦可以跑」的典型問題。
- **過大的映像檔體積**：採用單階段建構，且將所有原始碼、開發工具都打包進最終映像檔，造成不必要的體積膨脹和安全隱患。
- **低落的可靠性**：高度依賴外部網路連線，任何 npm registry 的不穩定都可能導致建置失敗。

---

### 3. 優化策略與實施步驟

為了解決上述痛點，我們採取了以下一系列現代化的 Docker 最佳實踐：

1. **建立依賴一致性 - 納管 **`**package-lock.json**`：
    - **措施**：將 `package-lock.json` 從 `.gitignore` 移除，並提交至版本控制。
    - **效益**：作為所有優化的基石，確保了依賴樹的完全鎖定，保證了在任何環境下建置結果的一致性。
2. **導入多階段建構 (**`**Multi-stage Build**`**)**：
    - **措施**：將 Dockerfile 分為 `builder` 階段和最終的生產階段。
    - **效益**：完全隔離了建置環境和運行環境。開發依賴、編譯工具等僅存在於 `builder` 階段，不會污染最終的生產映像檔。
3. **啟用 BuildKit 並優化 Docker 快取**：
    - **措施**：在 Dockerfile 頂部加入 `#syntax=docker/dockerfile:1` 並在建置時啟用 BuildKit。
    - **智慧分層**：調整指令順序為 `COPY package*.json` -> `RUN npm ci` -> `COPY . .`，最大化利用 Docker 的分層快取。
    - **進階快取掛載**：為 `npm ci` 和 `npm run build` 啟用 `-mount=type=cache`，分別持久化 npm 套件快取和前端打包工具的快取，即使在「冷啟動」時也能大幅提升速度。
4. **精簡化正式映像檔**：
    - **措施**：在最終階段，採用多行 `COPY` 的「白名單」模式，精準地只從 `builder` 階段複製運行時所必需的檔案和目錄。
    - **效益**：產出的映像檔體積最小、安全性最高，且 Dockerfile 本身成為了一份清晰的「部署清單」。

---

### 4. 前後 Dockerfile 對比

**優化前**

Dockerfile

```javascript
ARG BASE_IMAGE 
FROM $BASE_IMAGE AS builder 
WORKDIR /src 
COPY . . 
RUN npm install 
RUN npm run build 
RUN rm -r .git node_modules package-lock.json 
RUN npm install --only=prod 

FROM $BASE_IMAGE 
ARG NODE_ENV 
ENV NODE_ENV=$NODE_ENV 
WORKDIR /src 
COPY --from=builder /src /src 
RUN pm2 set pm2-logrotate:max_size 100M && pm2 set pm2-logrotate:retain 30
```

**✅ 優化後**

Dockerfile

```javascript
#syntax=docker/dockerfile:1
ARG BASE_IMAGE
FROM $BASE_IMAGE AS builder
WORKDIR /src
COPY package.json package-lock.json .npmrc ./
RUN --mount=type=cache,target=/root/.npm npm ci
COPY . .
RUN --mount=type=cache,target=/src/node_modules/.cache npm run build
RUN npm prune --production

FROM $BASE_IMAGE
ARG NODE_ENV
ENV NODE_ENV=$NODE_ENV
WORKDIR /src
COPY --from=builder /src/node_modules ./node_modules
COPY --from=builder /src/public ./public
COPY --from=builder /src/server ./server
COPY --from=builder /src/package.json ./package.json
COPY --from=builder /src/migrations ./migrations
COPY --from=builder /src/config ./config
COPY --from=builder /src/bin ./bin
COPY --from=builder /src/pm2-processes ./pm2-processes
COPY --from=builder /src/views ./views
COPY --from=builder /src/index.js ./index.js
RUN pm2 set pm2-logrotate:max_size 100M && pm2 set pm2-logrotate:retain 30
```

---

### 5. 後續建議

- **升級 AWS SDK**：在優化過程中發現專案使用的 AWS SDK v2 已停止支援，建議團隊將升級至 v3 作為高優先級任務，以避免潛在的安全風險。
- **探索進階打包**：若未來專案結構更複雜，可考慮引入「`builder` 內打包」的模式，讓 `npm` 腳本負責整理生產檔案，可使 Dockerfile 的最終 `COPY` 步驟縮減為一行，實現極致的簡潔與職責分離。

```javascript
#!/bin/bash -xe

# exit when any command failed
set -e
set -o pipefail

# declare
AWS_CREDENTIAL_PROFILE=$1
PHASE=$2
REGION="ap-northeast-2"
ALPHA_REPOSITORY_NAME="343270126633.dkr.ecr.ap-northeast-2.amazonaws.com/ms"
BETA_REPOSITORY_NAME="741328073657.dkr.ecr.ap-northeast-2.amazonaws.com/ms"

DOCKERFILE_DIR_PATH="$WORKSPACE/build"
GIT_TAG=`git describe --tags $(git rev-list --tags --max-count=1)`
GIT_HASH=`git rev-parse HEAD`
IMAGE_TAG="$PHASE-$GIT_TAG-$GIT_HASH"

if [[ $PHASE == alpha ]]; then
	BASE_IMAGE="343270126633.dkr.ecr.ap-northeast-2.amazonaws.com/pm2:14.17.0-alpine-mysqlcli-rediscli"
	IMAGE=$ALPHA_REPOSITORY_NAME:$IMAGE_TAG
else
	BASE_IMAGE="741328073657.dkr.ecr.ap-northeast-2.amazonaws.com/pm2:14.17.0-alpine-mysqlcli-rediscli"
	IMAGE=$BETA_REPOSITORY_NAME:$IMAGE_TAG
fi

if [ -z "$AWS_CREDENTIAL_PROFILE" ]; then
	echo "AWS_CREDENTIAL_PROFILE argument is required!"
	exit 1
fi

if [ -z "$PHASE" ]; then
	echo "PHASE argument is required!"
	exit 1
fi

# cmd
AWS="aws --profile $AWS_CREDENTIAL_PROFILE --region $REGION"

# aws ecr authentication
$($AWS ecr get-login --no-include-email)

# build docker base image
DOCKER_BUILDKIT=1 docker build \
	--build-arg BASE_IMAGE=$BASE_IMAGE \
	--build-arg NODE_ENV=$PHASE \
	-t $IMAGE \
	-f $DOCKERFILE_DIR_PATH/Dockerfile .

# push docker image
docker push $IMAGE

exit 0

```
