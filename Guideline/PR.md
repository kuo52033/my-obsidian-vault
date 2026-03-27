

- **Code**==*****==
- **Index Hints**==*****==
- **Virtual Explain**==*****==
- **Seeding SQL**==*****==
- **Test Cases*

Pull Request Principles

### [](https://app.gitbook.com/o/-LSmguN2bxAKDgeXkorc/s/-M2D50HaN7nWLf5FobFL/master#coding-style)Coding Style

- **Style Guide**
    
    - ​[https://github.com/airbnb/javascript](https://github.com/airbnb/javascript)​
        
    

- **ESLint**
    

- **Framework**
    
    - **MVC - Repository Pattern**
        
        - Controller
            
        
        - Service
            
        
        - Repository
            
        
        - Entity
            
        
    
    - **Request Life Cycle - Decorator Pattern**
        
        - express
            
            - middleware
                
            
        
        - fastify
            
            - ​[https://fastify.dev/docs/v2.15.x/Documentation/Lifecycle/](https://fastify.dev/docs/v2.15.x/Documentation/Lifecycle/)​
                
            
        
    
    - **CronJob**
        
        - **Orchestration Pattern**
            
        
    
    - **Express Style Guide**
        
        - ​[**https://app.gitbook.com/@ljit-io/s/style-guide/expressjs-style-guild**](https://app.gitbook.com/@ljit-io/s/style-guide/expressjs-style-guild)​
            
        
    
    - **Fastify Style Guide**
        
        - ​[**https://app.gitbook.com/o/-LSmguN2bxAKDgeXkorc/s/-M2D50HaN7nWLf5FobFL/~/changes/277/fastify-style-guild**](https://app.gitbook.com/o/-LSmguN2bxAKDgeXkorc/s/-M2D50HaN7nWLf5FobFL/fastify-style-guild)​
            
        
    
    - **Socket.IO Style Guide**
        
        - ​[**https://app.gitbook.com/o/-LSmguN2bxAKDgeXkorc/s/-M2D50HaN7nWLf5FobFL/~/changes/277/socket.io-style-guild**](https://app.gitbook.com/o/-LSmguN2bxAKDgeXkorc/s/-M2D50HaN7nWLf5FobFL/socket.io-style-guild)​
            
        
    

### [](https://app.gitbook.com/o/-LSmguN2bxAKDgeXkorc/s/-M2D50HaN7nWLf5FobFL/master#data-structure-and-time-complexity)Data Structure & Time Complexity

- **Data Structure**
    
    - Array/Object/Set/Map
        
        - Array
            
            - ​[https://developer.mozilla.org/zh-TW/docs/Web/JavaScript/Reference/Global_Objects/Array](https://developer.mozilla.org/zh-TW/docs/Web/JavaScript/Reference/Global_Objects/Array)​
                
            
        
        - Object
            
            - ​[https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Object](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Object)​
                
            
        
        - Set
            
            - ​[https://developer.mozilla.org/zh-TW/docs/Web/JavaScript/Reference/Global_Objects/Set](https://developer.mozilla.org/zh-TW/docs/Web/JavaScript/Reference/Global_Objects/Set)​
                
            
        
        - Map
            
            - ​[https://developer.mozilla.org/zh-TW/docs/Web/JavaScript/Reference/Global_Objects/Map](https://developer.mozilla.org/zh-TW/docs/Web/JavaScript/Reference/Global_Objects/Map)​
                
            
        
    

- **Time Complexity**
    
    - O(1) > O(n) > O(n^2)
        
    

- **Node.JS Event Loop**
    
    - **Don't Use CPU-Incentivie Modules/Utils/Functions ASAP.**
        
        - JSON.parse
            
        
        - JSON.stringify
            
            - use fast-json-stringify
                
            
        
        - Regexp
            
        
        - Crypto
            
        
        - Zlib
            
        
        - FS
            
        
    

Database

Query Using Index

Preferred Queried By Covering Index > Primary Key > Secondary Index

As Possible As Use Attributes

Don't Use SELECT * FROM table;

As Possible As Query Smallest Size Of Data/Rows/Documents

Add Limit

As Possible As Order By Using Index

Use Composite Index

Minimize Round Time Trips Of Database Accesses

Use IN/OR/AND

Don't Use For Loop Query

Use BULK INSERT

Don't Use For Loop Query

Use BULK INSERT IGNORE DUPLICATE ON

Don't Use For Loop Query

Prevent Repeatedly Query Same Record

Cache (Redis)

Use HASH To Store JS Object

Don't Use JSON.parse, JSON.stringify Store JS Object AS String.

Use Set To Store Unique Items

Use List To Store Array

Use Bitfield To Store Boolean

Set Expire For Each Document

Behavior