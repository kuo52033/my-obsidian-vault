---
notion-id: 1f95a6e2-1812-80a3-89d9-c8f0743f238b
---
## Background

In a multi-project Kubernetes cluster, the `nginx-ingress-controller` in the `bms` namespace experienced frequent `Sync` events (21,936 occurrences over three days), caused by the `status.loadBalancer.ingress.hostname` of the `bms-management-ingress` Ingress resource repeatedly changing to Network Load Balancers (NLBs) associated with other projects. Initially, the `nginx-ingress-controller-bms` Service was configured with `service.beta.kubernetes.io/aws-load-balancer-name: "ae65c98b2e9a648a2a7b96e40062ada7"`, which stabilized the Service's `status.loadBalancer.ingress`. However, the Ingress continued to exhibit instability, likely due to interference from other projects' controllers, lack of namespace isolation, and potential NLB target group health issues.

To address this, the following actions were implemented:

1. Added `nodeAffinity` and `podAntiAffinity` to distribute `nginx-ingress-controller` Pods across nodes labeled `app: bms, env: production`.
2. Set `spec.ingressClassName: bms` in the Ingress without creating an `IngressClass` resource.

This report evaluates these actions, provides recommendations for further improvement, and outlines steps to ensure long-term stability across all projects in the cluster.

## Problem Analysis

- **Frequent Sync Events**: The `nginx-ingress-controller` triggered `Sync` events due to the `status.loadBalancer.ingress.hostname` of `bms-management-ingress` changing to other projects' NLBs.
- **NLB Name Conflict**: The original NLB name (`ae65c98b2e9a648a2a7b96e40062ada7`) was potentially used by other projects, causing interference.
- **Unhealthy NLB Target Groups**: Misconfigured Services or nodes in other projects may have caused unhealthy target groups, indirectly affecting NLB stability.
- **Controller Interference**: Other projects' `nginx-ingress-controller` instances likely lacked `-watch-namespace`, allowing them to update Ingress resources in the `bms` namespace.
- **IngressClass Configuration**: Setting `ingressClassName: bms` without an `IngressClass` resource may lead to inconsistent behavior in a multi-controller environment.

## Actions Taken

3. **Distributed Pods with** `nodeAffinity` **and** `podAntiAffinity`:
    - Added `nodeAffinity` to ensure Pods are scheduled only on nodes labeled `app: bms, env: production`:
```yaml
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: app
              operator: In
              values:
                - bms
            - key: env
              operator: In
              values:
                - production

```
    - Added `podAntiAffinity` to distribute Pods across different nodes:
```yaml
podAntiAffinity:
  preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchLabels:
            app.kubernetes.io/name: ingress-nginx
        topologyKey: kubernetes.io/hostname

```
    - **Effect**:
        - `nodeAffinity` aligns Pod scheduling with the Service's `service.beta.kubernetes.io/aws-load-balancer-target-node-labels: "app=bms,env=production"`, ensuring NLB target groups only include correct nodes.
        - `podAntiAffinity` prioritizes spreading `nginx-ingress-controller` Pods (labeled `app.kubernetes.io/name: ingress-nginx`) across different nodes (based on `kubernetes.io/hostname`), enhancing high availability and load distribution.
        - Together, these configurations improve NLB target group health and reduce the risk of single-node failures.
    - **Risk**: If insufficient nodes are labeled `app: bms, env: production`, Pod scheduling may be constrained. The soft `podAntiAffinity` allows Pods to schedule on the same node if necessary, avoiding scheduling failures.
4. **Set** `ingressClassName` **Without** `IngressClass`:
    - Added `spec.ingressClassName: bms` to `bms-management-ingress` without creating an `IngressClass` resource.
    - **Effect**: Ensures the Ingress is managed by the `bms` namespace's controller, assuming it is configured with `-ingress-class=bms`. Reduces interference from other controllers if they use different `ingress-class` values.
    - **Risk**: Without an `IngressClass` resource, other controllers using `-ingress-class=bms` may interfere, and the configuration lacks standardization in a multi-controller environment.

## Effectiveness Evaluation

- **Target Group Health**: `nodeAffinity` ensures Pods run on correctly labeled nodes, and `podAntiAffinity` distributes Pods across nodes, aligning with `aws-load-balancer-target-node-labels` and resolving unhealthy target group issues.
- **Ingress Stability**: Setting `ingressClassName: bms` is effective if the `nginx-ingress-controller` is configured with `-ingress-class=bms` and no other controllers use the same value. However, without an `IngressClass` resource and namespace isolation for other projects, Ingress `hostname` instability may persist due to controller interference.
- **Remaining Risk**:
    - Other projects' controllers without `-watch-namespace` may update `bms-management-ingress`, causing `hostname` jumps.
    - Dynamic NLB names are harder to manage and may lead to future misconfigurations.
    - Lack of an `IngressClass` resource reduces configuration clarity and standardization.

## Recommendations for Improvement

To ensure long-term stability and prevent recurrence, the following improvements are recommended:

5. **Use a Unique NLB Name**:
    - Restore `service.beta.kubernetes.io/aws-load-balancer-name` with a descriptive, unique name (e.g., `bms-prod-nlb`) to improve manageability and avoid future conflicts:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-ingress-controller-bms
  namespace: bms
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-name: "bms-prod-nlb"
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "tcp"
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-target-node-labels: "app=bms,env=production"
    service.beta.kubernetes.io/aws-load-balancer-healthcheck-path: "/healthz"
    service.beta.kubernetes.io/aws-load-balancer-healthcheck-port: "10254"
spec:
  type: LoadBalancer
  selector:
    app.kubernetes.io/name: ingress-nginx
    app.kubernetes.io/part-of: ingress-nginx
  ports:
    - name: http
      port: 80
      protocol: TCP
      targetPort: http
    - name: https
      port: 443
      protocol: TCP
      targetPort: http
  externalTrafficPolicy: "Local"

```
    - Apply:
```shell
kubectl apply -f service.yaml

```
    - Verify NLB:
```shell
aws elbv2 describe-load-balancers --names bms-prod-nlb --region <your-region>

```
6. **Create** `IngressClass` **Resource**:
    - Define an `IngressClass` for clarity and standardization:
```yaml
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: bms
spec:
  controller: k8s.io/ingress-nginx

```
    - Apply:
```shell
kubectl apply -f ingress-class.yaml

```
    - Ensure the Ingress references it:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: bms-management-ingress
  namespace: bms
spec:
  ingressClassName: bms
  rules:
  - host: bms-m.rcppay.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: bms-management-service
            port:
              number: 80

```
    - Apply:
```shell
kubectl apply -f ingress.yaml

```

## Preventive Measures

- **Enforce Namespace Isolation**: Require all `nginx-ingress-controller` instances to set `-watch-namespace` to prevent cross-namespace interference.
- **Mandate** `IngressClass`: Create `IngressClass` resources for each project to ensure clear controller mapping.
- **Monitor NLB Health**: Regularly check NLB target groups and node labels to prevent unhealthy targets.
- **Monitor Stability**:
    - Monitor Ingress:
```shell
kubectl get ingress bms-management-ingress -n bms -o yaml --watch

```
    - Check for Sync events:
```shell
kubectl get events -n bms

```
    - Verify application accessibility:
```shell
curl bms-m.rcppay.com

```

## Conclusion

The implemented actions—adding `nodeAffinity` and `podAntiAffinity`, and setting `ingressClassName: bms`—have significantly improved system stability by ensuring Service consistency, healthy NLB target groups, and partial controller isolation. The addition of `podAntiAffinity` enhances high availability by distributing `nginx-ingress-controller` Pods across nodes, reducing the risk of single-node failures. However, to fully resolve potential Ingress `hostname` jumps, creating an `IngressClass` resource, using a unique NLB name, and enforcing namespace isolation for other projects are critical. These steps, combined with regular monitoring and standardized configurations, will ensure long-term stability in a multi-project Kubernetes environment.