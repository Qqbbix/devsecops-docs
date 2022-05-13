# Container & Kubernetes Security Workshop

## Prerequisite

```bash
kubectl config set-context $(kubectl config current-context) --namespace=training[X]-bookinfo-dev
```

## Privilege Container

```bash
docker run -it --rm alpine sh
fdisk -l
exit
docker run --privileged -it --rm alpine sh
fdisk -l
exit
```

## Distroless Image

* Update `Dockerfile` to use distroless

```Dockerfile
FROM node:16.15.0-alpine3.15 AS build-env
WORKDIR /usr/src/app/
COPY src/ ./
RUN npm install

FROM gcr.io/distroless/nodejs:16
WORKDIR /usr/src/app/
COPY --from=build-env /usr/src/app/ ./
EXPOSE 8080
CMD ["ratings.js", "8080"]
```

```bash
cd ~/ratings/

# Build and up
docker compose up --build -d

# See the size a little bit difference
docker images

# We can not shell to container anymore
docker exec -it ratings-ratings-1 sh

# Destroy everything
docker compose down
```

## RBAC

* Create `rbac.yaml` in `~/k8s/` directory

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: training[X]-read-write
  namespace: training[X]-bookinfo-dev
rules:
- apiGroups:
  - ""
  - "apps"
  - "networking.k8s.io"
  resources: ["*"]
  verbs:
  - get
  - list
  - watch
  - create
  - update
  - patch
  - delete
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: training[X]-read-write-binding
  namespace: training[X]-bookinfo-dev
roleRef:
  kind: Role
  name: training[X]-read-write
  apiGroup: rbac.authorization.k8s.io
subjects:
  - kind: User
    name: training[X]@opsta.net
```

```bash
# Test the command first
kubectl get pods --namespace kube-system

cd ~/k8s
# Wait for instructor to add you as k8s admin first
kubectl apply -f rbac.yaml
# Remove cache first
rm -rf ~/.kube/cache/
# Wait for instructor to update you as normal user
kubectl get pod --namespace training[X]-bookinfo-dev
kubectl get pod --all-namespaces
kubectl get namespaces
kubectl auth can-i get pods --namespace training[X]-bookinfo-dev
kubectl auth can-i get pods --namespace kube-system

# Wait for instructor to add you as kubernetes developer role again
kubectl get pods --namespace kube-system
```

## Kubernetes Policies with Kyverno

* Create `privileged-container.yaml` in `~/k8s/` directory

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
  namespace: training[X]-bookinfo-dev
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 1
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.21.6-alpine
        ports:
        - containerPort: 80
        securityContext:
          privileged: true
```

```bash
# Uncomment priviledge line first
kubectl apply -f privileged-container.yaml
kubectl get pods
kubectl exec -it nginx-deployment-8668b79b4d-j92np -- sh
fdisk -l

# Comment out and create nginx with privileged container
kubectl apply -f privileged-container.yaml
kubectl get pods
kubectl exec -it nginx-deployment-8668b79b4d-j92np -- sh
fdisk -l
# You will see more privileged
exit
# Delete deployment
kubectl delete -f privileged-container.yaml
```

* Apply Kyverno Policy by creating `kyverno-disallow-privileged-containers.yaml` in `~/k8s/` directory

```yaml
apiVersion: kyverno.io/v1
kind: Policy
metadata:
  name: disallow-privileged-containers
  namespace: training[X]-bookinfo-dev
  annotations:
    policies.kyverno.io/title: Disallow Privileged Containers
    policies.kyverno.io/category: Pod Security Standards (Baseline)
    policies.kyverno.io/severity: medium
    policies.kyverno.io/subject: Pod
    kyverno.io/kyverno-version: 1.6.0
    kyverno.io/kubernetes-version: "1.22-1.23"
    policies.kyverno.io/description: >-
      Privileged mode disables most security mechanisms and must not be allowed. This policy
      ensures Pods do not call for privileged mode.
spec:
  validationFailureAction: enforce
  background: true
  rules:
    - name: privileged-containers
      match:
        any:
        - resources:
            kinds:
              - Pod
      validate:
        message: >-
          Privileged mode is disallowed. The fields spec.containers[*].securityContext.privileged
          and spec.initContainers[*].securityContext.privileged must be unset or set to `false`.
        pattern:
          spec:
            =(ephemeralContainers):
              - =(securityContext):
                  =(privileged): "false"
            =(initContainers):
              - =(securityContext):
                  =(privileged): "false"
            containers:
              - =(securityContext):
                  =(privileged): "false"
```

```bash
# Apply Kyverno policy
kubectl apply -f kyverno-disallow-privileged-containers.yaml
# Try to apply priviledge container again and see the error while applying manifest
kubectl apply -f privileged-container.yaml
# Delete Kyverno policy
kubectl delete -f kyverno-disallow-privileged-containers.yaml
```

## Network Policy

* Create `networkpolicy-block-ns.yaml` in `~/k8s/` directory

```yaml
kind: NetworkPolicy
apiVersion: networking.k8s.io/v1
metadata:
  name: block-external-namespace-traffic
  namespace: training[X]-bookinfo-prd
spec:
  podSelector:
    matchLabels:
  ingress:
  - from:
    - podSelector: {}
```

```bash
# Test accessing other namespaces first
kubectl get service
kubectl get pod
kubectl exec -it bookinfo-dev-ratings-mongodb-b7d86f6f6-dmgcd -- bash
curl http://bookinfo-dev-ratings:8080/health
curl http://bookinfo-prd-ratings.training1-bookinfo-prd.svc.cluster.local:8080/health
exit

# Apply Network Policy
kubectl apply -f networkpolicy-block-ns.yaml

# Test accessing other namespaces again
kubectl exec -it bookinfo-dev-ratings-mongodb-b7d86f6f6-dmgcd -- bash
curl http://bookinfo-prd-ratings.training1-bookinfo-prd.svc.cluster.local:8080/health
exit

# Delete Network Policy
kubectl delete -f networkpolicy-block-ns.yaml
```

## Non-root Container

* Create `immutable-infrastructure.yaml` in `~/k8s/` directory

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: busybox
  namespace: training[X]-bookinfo-dev
spec:
  containers:
  - name: busybox
    image: busybox
    command: ['sleep', '3600']
    securityContext:
      readOnlyRootFilesystem: true
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
```

```bash
# Apply Immutable Infrastructure Pod
kubectl apply -f immutable-infrastructure.yaml
kubectl exec -it busybox -- sh

id
touch test
exit

# Try comment all securityContext and apply again
kubectl delete -f immutable-infrastructure.yaml
kubectl apply -f immutable-infrastructure.yaml
kubectl exec -it busybox -- sh

id
touch test
ls -l
exit

# Delete Immutable Infrastructure Pod
kubectl delete -f immutable-infrastructure.yaml
```

## Navigation

* Previous: [Automation Security Workshop](10-automation-security.md)
* [Home](../README.md)
