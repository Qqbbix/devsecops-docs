# Kubernetes Workshop

## Getting started

```bash
# Get kubeconfig from GKE
gcloud container clusters get-credentials k8s --project zcloud-cicd --zone asia-southeast1-a
# Check if it can connect to cluster
kubectl version
# View Cluster Information
kubectl cluster-info
# Show all pods
kubectl get pod --all-namespaces
```

## Setup your own namespaces

```bash
# Show all namespaces
kubectl get namespaces
# Show current cluster connection configuration
kubectl config get-contexts
# Create your own namespaces
kubectl create namespace training[X]-cli
# Show your newly created namespace
kubectl get namespaces
# Set default namespace
kubectl config set-context $(kubectl config current-context) --namespace=training[X]-cli
kubectl config get-contexts
```

## Create Pod and Deployment

```bash
# Create nginx deployment
kubectl create deployment nginx --image=nginx
# Show deployments
kubectl get deployment
# Show pods
kubectl get pods
# Show deployments and pods at the same time in one command
kubectl get deployment,pod
# Show nginx deployment detail
kubectl describe deployment nginx
# Show nginx pod detail
kubectl describe pod nginx
# Try to delete pod and see deployment recreate pod again
kubectl delete pod nginx-[XXXXXXXXXX-XXXXX] --wait=false && watch -n1 kubectl get deployment,pod
```

## Create Service

* Create Service with type `LoadBalancer`

```bash
# Expose service load balancer to nginx deployment port 80
kubectl expose deployment nginx --type LoadBalancer --port 80 --name nginx-lb
# Wait to see public ip to be active and test it
kubectl get services -w
```

* Create Service with type `ClusterIP` and try to access with proxy

```bash
kubectl expose deployment nginx --type ClusterIP --port 80 --name nginx-cip
kubectl get service
kubectl proxy --port=8080
# Click preview port 8080
# access via /api/v1/namespaces/training[X]-cli/services/nginx-cip:80/proxy/
```

* Using port forward to access directly to service nginx ClusterIP

```bash
# Port forward from service nginx clusterip port 80 to local port 8080
kubectl port-forward service/nginx-cip 8080:80
# Use Web Preview port 8080 to see nginx is working
```

## Scale service and change docker image

```bash
# Scale pod to 3 replicas
kubectl scale deployment nginx --replicas=3
# Show deployment and pod status
kubectl get deployment,pod
# Change nginx deployment to use apache instead
kubectl set image deployment nginx nginx=httpd:2.4-alpine && watch -n1 kubectl get pod
# See change with port-forward command
kubectl get deployment
kubectl describe deployments nginx
```

## Rollback deployment

```bash
# Show deployment history
kubectl rollout history deployment nginx
# Rollback one version
kubectl rollout undo deployment nginx
# See change
kubectl rollout history deployment nginx
kubectl describe deployment nginx
```

## Label and Selector

```bash
# Create new apache deployment
kubectl create deployment apache --image=httpd:2.4-alpine
# Scale apache deployment to 3 replicas
kubectl scale deployment apache --replicas=3
# See change
kubectl get deployment,pod
# See the label and selector
kubectl describe deployments nginx
kubectl describe service nginx-cip
# See the label
kubectl describe deployments apache
# Set service nginx to select apache deployment label instead
kubectl set selector service nginx-cip 'app=apache'
# Revert selector back
kubectl set selector service nginx-cip 'app=nginx'
```

## Kubernetes Utilities Commands

```bash
# Show pod log
kubectl scale deployment nginx --replicas=1
kubectl scale deployment apache --replicas=1
kubectl get pod
kubectl logs nginx-[xxxxxxxxxx-xxxxx] -f
# Enter inside container
kubectl get service
kubectl exec -it apache-[xxxxxxxxxx-xxxxx] -- sh
ping nginx-cip
exit
# View node information
kubectl get nodes
kubectl describe nodes gke-k8s-default-pool-[xxxxxxxx-xxxx]
```

## Clear Everything

```bash
kubectl delete deployment nginx apache
kubectl delete service nginx-cip nginx-lb
kubectl get deployment,pod,service
kubectl delete namespace training[X]-cli
```

## Navigation

* Previous: [Local Development Preparation](02-preparation.md)
* [Home](../README.md)
* Next: [Kubernetes Manifest File Workshop](04-k8s-manifest.md)
