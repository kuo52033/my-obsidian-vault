---
notion-id: 5bff6ddb-4469-41a2-a7b1-59e5fc01fca4
---
Dom ( Document Object Model) 

- The document object is our entry point into the world of the Dom，it contains representations of all the content on a page，plus tons of useful methods and properties
- The style property is going to set the inline style，the better option is to create a css class and then apply that class
- 

![[dom.png]]

![[dom2.png]]

- onclick is a object，so it just can only set one callback function，but addEventListener allows us to have as many callbacks as we want
- event bubbling : 指的是當某個事件發生在某個DOM element上（如：點擊），這個事件會觸發DOM element的event handler，接下來會再觸發他的parent的event handler，以及parent的parent的event handler…直到最上層。 可以透過 e.stopPropagation() 來防止
