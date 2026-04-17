---
notion-id: 3a0f5597-2919-4c2c-b924-af5b2f6bf5bc
---
[[Scalability, High Availability, Elasticity]]

ELB = Elastic Load Balancer

### why load balncer

- Spread load across mutiple downstream instances
- Expose a single point of access (DNS) to your application
- Seamlessly handle failures of downstream instances
- Do regular health checks to instances
- Provide SSL termination (HTTPS) for your websites
- High availability across zones

![[螢幕擷取畫面_2024-03-24_123816.png]]

# ASG

ASG = Auto Scaling Group

- Scale out (add EC2 instance) to match an increased load
- Scale in (remove EC2 instance) to match an decreased load
- Replace unhealthy instances 

### scaling strategies

- Manual Scaling: update the size of an ASG manually
- Dynamic Scaling: Respond to changing demand
    - Simple / Step Scaling
        - when a CloudWatch alarm is triggered (example CPU > 70%), then add 2 units
        - when a CloudWatch alarm is triggered (example CPU < 30%), then remove 1
    - Target Tracking Scaling
        - Example: i want the average ASG CPU to stay at around 40%
    - Scheduled Scaling
        - Example: increase the min capacity to 10 at 5pm on Fridays


![[螢幕擷取畫面_2024-03-24_133602.png]]