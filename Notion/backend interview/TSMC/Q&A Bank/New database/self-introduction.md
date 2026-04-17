---
notion-id: 3395a6e2-1812-80ab-9e19-c2431cc08a8f
base: "[[New database.base]]"
指派: []
狀態: 進行中
---
你好，我是郭峻維，畢業於輔仁大學資工系，目前有三年半後端開發經驗，主要專注在 Node.js 以及雲原生架構，過去的工作是在設計與優化穩定現有的後端系統。
我的經歷大致分為兩個階段。

前期主要專注在產品開發，負責API 設計與實作，使用 MySQL、 MongoDB 做為資料存取，透過 Redis 做快取和訊息的處理，在這個階段熟悉了後端架構設計和 Scrum 開發流程。

後期則擔任新專案的後端負責人，主導多個系統從零到上線，負責整體架構，CI/ CD 建置，也參與維運和問題的排查。

這段過程中，我累積了幾個經驗。

在穩定性方面，曾經遇過系統在高負載下出現問題，後來也主導了基礎設施，以及 CI/CD pipline 的優化，提升整體部屬效率及穩定度。

在效能方面，有處理過 API latency 過高和資料庫慢查詢的問題，還有實作像是 streaming I/O 等方式來優化記憶體使用 。
我離開前公司的原因，是希望能進一步在更大規模、架構更複雜的環境中成長，這也是我這次來面試的主要動機。
以上是我的自我介紹，謝謝。

Hi, I'm Kuo Chun-Wei, and I'm 26 years old, I graduated from Fu Jen Catholic University with a degree in computer science. I have around three and a half year of backend development experience, primarily working with Node.js, SQL, NoSQL and AWS cloud service.
I divide my experience at my previous company into two phase. In my first phase, I worked on building customized product features for different clients, collaborating closely with frontend and backend engineers as well as PMs, and during that time I became familiar with backend architecture design and the Scrum workflow.
In the second phase, I became the backend owner of new projects, I led at least two systems from scratch to production, and I was responsible for the overall architecture planning, development prioritization, and system maintenance.
Through that experience I got a lot of real-world lessons. On the reliability side, I dealt with the system issues under high load, which made me realize how important good system architecture and monitoring are. After that, I also led infrastructure improvements, including EKS cluster isolation strategies and CI/CD optimization.
On the performance side, I’ve investigated issues like high API latency and slow database queries, and I learned how to systematically identify bottlenecks and improve them.
Beyond that, I've also been involved in database and Kubernetes version upgrades.
I have now left that company because I feel that the systems and operations experience I could gain there had reached a certain stage. I want to continue growing in a larger and more complex environment, and challenge myself further. That's really what brought me here today.

That's a quick overview of my background — happy to dive into any part of it.

---

## 預期追問

面試官聽完自介最可能的追問方向：

| 他可能問 | 你的對應故事 |
| --- | --- |
| 報表 20s→1s 怎麼做的？ | Story 9（SQL 效能調校） |
| OOM 怎麼解的？ | Story 3（Stream I/O） |
| Cluster 隔離具體怎麼做？ | Story 1 + Story 8 |
| WebSocket 架構細節？ | Story 5（BullMQ） |
| Go 的 side project？ | go-q 的設計（Redis-backed MQ） |
| 為什麼想離開現在的公司？ | 準備一個正面的理由（見下方） |

## 「為什麼想離開」的回答模板

> 「現在的公司讓我從零建立了完整的後端和 DevOps 經驗，我很感謝這段歷程。但公司規模較小，系統的流量和複雜度有天花板。我希望到一個更大規模的環境，面對更高並行量和更嚴格的穩定性要求，繼續成長。台積的 IT 部門正在推 Cloud Native，技術棧跟我的經驗高度吻合，而且產線系統對可靠性的要求，是我目前環境無法練到的。」

重點：**不要批評現公司**，只說「想要更大的舞台」。