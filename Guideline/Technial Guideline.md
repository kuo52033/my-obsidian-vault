

- Express Coding Style
    - Implement **Create Order** API
        
        - Controller
            
            - route, hook
                
            
        
        - Service
            
        
        - Repository/Store
            
            - fn naming convention
                
            
            - transaction
                
            
        
        - Entity/Model
            
            - findAll, findOne, update, create, bulkCreate
                
            
        
    

- Fastify Coding Style
    
    - Implement **Create Order** API
        
        - Controller
            
            - schema, preRequest, preHandler, handler, onResponse...
                
            
        
        - Service
            
        
        - Repository/Store
            
            - fn naming convention
                
            
            - transaction
                
            
        
        - Entity/Model
            
            - findAll, findOne, update, create, bulkCreate
                
            
        
    

- JS
    
    - ​[https://eyesofkids.gitbooks.io/javascript-start-from-es6/content/](https://eyesofkids.gitbooks.io/javascript-start-from-es6/content/) 1.5
        
    

- Node.JS
    
    - Event Loop
        
        - ​[https://nodejs.org/en/learn/asynchronous-work/event-loop-timers-and-nexttick](https://nodejs.org/en/learn/asynchronous-work/event-loop-timers-and-nexttick)​
            
        
        - ​[https://nodejs.org/en/learn/asynchronous-work/dont-block-the-event-loop](https://nodejs.org/en/learn/asynchronous-work/dont-block-the-event-loop)​
            
        
    
    - Why/What/When
        
        - Why Node.JS is good at network IO?
            
        
        - What is libuv responsible to?
            
        
        - What does Node.JS worker thread responsible to?
            
        
        - How does it work on Node.JS Event Loop
            
            - array.map
                
            
            - JSON.parse/JSON.stringify
                
            
            - crypto
                
            
            - fs
                
            
            - dns
                
            
            - fetch(127.0.0.1)
                
            
            - fetch(example.com)
                
            
            - sql(SELECT * FROM users WHERE id=1)
                
            
        
        - Why Fastify Not Express?
            
            - Routing
                
                - Redux Tree VS Regex
                    
                
            
            - Serialization
                
                - fast-json-stringify VS JSON.stringify
                    
                
            
            - Request Memory Usage Implematation
                
                - Event-Emitter VS Call-Stack
                    
                
            
        
    

- MySQL
    
    - Normalize (1~3 nth)
        
        - Non-Normalize
            
        
    
    - Data Type
        
        - Integer/String...
            
            - Best Query Performance Using Integer
                
            
        
    
    - Index
        
        - Primary/Unique/Index Key
            
        
        - B+ Tree
            
            - B Tree
                
            
        
        - Composite Index
            
            - SELECT * FROM users WHERE male=1 ORDER BY age;
                
            
        
        - Clustered Index
            
        
        - Covering Index
            
        
    
    - Transaction ACID
        
        - Lock
            
            - Share/Exclusive Lock
                
            
            - Record Lock
                
            
            - Gap Lock
                
            
            - Next key Lock
                
            
            - Insert Intention Lock
                
            
            - Increment Lock (3 modes)
                
                - 5.7 mode 2
                    
                
                - 8.0 mode 3
                    
                
            
        
        - Isolation Level
            
            - Repeatable Read
                
            
        
        - Reference
            
            - https://dev.mysql.com/doc/refman/5.7/en/innodb-locking.html
                
            
            - https://juejin.cn/post/6844903666856493064