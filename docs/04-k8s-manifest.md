# Kubernetes Manifest Files Workshop

## Prepare Kubernetes Environment

```bash
kubectl create namespace training[X]-manifest
kubectl config set-context $(kubectl config current-context) --namespace=training[X]-manifest
```

## Deploy Pod with Manifest File

* `mkdir ~/k8s` to create folder for Kubernetes Manifest File
* Create `01-pod.yaml` file with below content

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: busybox
  namespace: training[X]-manifest
spec:
  containers:
  - name: busybox
    image: busybox
    command:
    - sleep
    - "3600"
```

* Create pod from manifest file

```bash
cd ~/k8s
# Create resources as configured in manifest file
kubectl apply -f 01-pod.yaml
kubectl get pod

# Try to get inside pod
kubectl exec -it busybox -- sh
ping www.google.com
exit
```

## How to check syntax for manifest file

```bash
# Show all api resources in Kubernetes Cluster
kubectl api-resources
# Show manifest syntax for Kind = pod
kubectl explain pod
# Show all manifest syntax for Kind = pod
kubectl explain pod --recursive
# Show manifest spec syntax for Kind = pod
kubectl explain pod.spec
# Show manifest syntax for Kind = deployment
kubectl explain deployment
```

## Deployment and Service Manifest File

* Create `02-apache-deployment.yaml` file with below content

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: apache
  namespace: training[X]-manifest
spec:
  replicas: 3
  selector:
    matchLabels:
      app: apache
  template:
    metadata:
      labels:
        app: apache
    spec:
      containers:
      - image: httpd:2.4.53-alpine3.15
        name: apache
```

* Create `02-apache-service.yaml` file with below content

```yaml
apiVersion: v1
kind: Service
metadata:
  name: apache
  namespace: training[X]-manifest
spec:
  type: ClusterIP
  ports:
  - port: 80
  selector:
    app: apache
```

```bash
kubectl apply -f 02-apache-deployment.yaml -f 02-apache-service.yaml
kubectl get deployments
kubectl port-forward service/apache 8080:80
# Click preview port 8080
```

## Clean every deployment and service

```bash
# Delete from manifest files
kubectl delete -f .
kubectl delete namespace training[X]-manifest
```

## Navigation

* Previous: [Kubernetes Command Line Workshop](03-k8s-cli.md)
* [Home](../README.md)
* Next: [Deploy Bookinfo Rating Service on Kubernetes Workshop](05-k8s-rating.md)
