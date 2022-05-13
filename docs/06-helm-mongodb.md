# Deploy MongoDB with Helm Chart

## Add Helm Bitnami Charts

```bash
# Add bitnami charts repository
helm repo add bitnami https://charts.bitnami.com/bitnami
# List repo
helm repo list
# Update repo
helm repo update
```

## Deploy basic MongoDB with Helm Charts from Kubeapps Hub

* Go to <https://artifacthub.io/packages/helm/bitnami/mongodb> to see MongoDB Helm Charts description
* Deploy basic MongoDB

```bash
# Check helm release
helm list
# Deploy MongoDB Helm Charts
helm install mongodb bitnami/mongodb --set persistence.enabled=false
# Check helm release again
helm list
```

* Check if MongoDB is working

```bash
# Check resources
kubectl get pod,deployment,service
```

* Connect to MongoDB

```bash
# Check secret
kubectl get secret
kubectl describe secret mongodb

# Get MongoDB root password
export MONGODB_ROOT_PASSWORD=$(kubectl get secret mongodb \
  -o jsonpath="{.data.mongodb-root-password}" | base64 --decode)
# Create another pod to connect to MongoDB via mongo cli command
kubectl run mongodb-client --rm --tty -i --restart='Never' --image bitnami/mongodb:5.0.8-debian-10-r12 \
  --command -- mongo admin --host mongodb --authenticationDatabase admin -u root -p $MONGODB_ROOT_PASSWORD
show dbs
exit
```

## Deploy custom configuration MongoDB with Helm Value

### Prepare Helm Value file

* Check `values.yaml` on <https://github.com/bitnami/charts/tree/master/bitnami/mongodb> to see all configuration
* Create secret for MongoDB password

```bash
kubectl create secret generic bookinfo-dev-ratings-mongodb-secret \
  --from-literal=mongodb-passwords=CHANGEME \
  --from-literal=mongodb-root-password=CHANGEME
```

* `mkdir ~/ratings/k8s/helm-values/` and create `values-bookinfo-dev-ratings-mongodb.yaml` file inside `helm-values` directory and put following content

```yaml
image:
  tag: 5.0.8-debian-10-r12
auth:
  enabled: true
  username: ratings
  database: ratings
  existingSecret: bookinfo-dev-ratings-mongodb-secret
persistence:
  enabled: false
initdbScriptsConfigMap: bookinfo-dev-ratings-mongodb-initdb
```

### Create initial script with Config Map

* Run following commands to create configmap

```bash
cd ~/ratings/

# Create configmap
kubectl create configmap bookinfo-dev-ratings-mongodb-initdb \
  --from-file=databases/ratings_data.json \
  --from-file=databases/script.sh

# Check config map
kubectl get configmap
kubectl describe configmap bookinfo-dev-ratings-mongodb-initdb
```

### Deploy MongoDB with Helm Value file

```bash
# Delete first mongodb release
helm list
helm uninstall mongodb

# Deploy new MongoDB with Helm Value
helm install -f k8s/helm-values/values-bookinfo-dev-ratings-mongodb.yaml \
  bookinfo-dev-ratings-mongodb bitnami/mongodb
```

* Check if MongoDB is working properly with imported data

```bash
# Create another pod to connect to MongoDB via mongo cli command
kubectl run mongodb-client --rm --tty -i --restart='Never' --image bitnami/mongodb:5.0.8-debian-10-r12 \
  --command -- mongo admin --host bookinfo-dev-ratings-mongodb --username root --password CHANGEME
show dbs
use ratings
show collections
db.ratings.find()
exit
```

## Update Ratings Service Manifest File

* Update Ratings Service Manifest File to read data from MongoDB in `k8s/ratings-deployment.yaml` file

```yaml
...
        env:
        - name: SERVICE_VERSION
          value: v2
        - name: MONGO_DB_URL
          value: mongodb://bookinfo-dev-ratings-mongodb:27017/ratings
        - name: MONGO_DB_USERNAME
          value: ratings
        - name: MONGO_DB_PASSWORD
          valueFrom:
            secretKeyRef:
              name: bookinfo-dev-ratings-mongodb-secret
              key: mongodb-passwords
...
```

* Run `kubectl apply -f k8s/` and test if ratings service still working
* Commit and push code to Git

## Navigation

* Previous: [Deploy Bookinfo Rating Service on Kubernetes Workshop](05-k8s-rating.md)
* [Home](../README.md)
* Next: [Deploy Rating Service with Helm Chart Workshop](07-helm-rating.md)
