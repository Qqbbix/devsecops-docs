# Deploy Rating Service with Helm Chart

## Create Helm Chart for Ratings Service

* Delete current Ratings Service first with command `kubectl delete -f k8s/`
* `mkdir ~/ratings/k8s/helm` to create directory for Ratings Helm Charts
* Create `Chart.yaml` file inside `helm` directory and put below content

```yaml
apiVersion: v1
description: Bookinfo Ratings Service Helm Chart
name: bookinfo-ratings
version: 1.0.0
appVersion: 1.0.0
home: https://bookinfo.demo.opsta.co.th/training[X]/ratings
maintainers:
  - name: training[X]
    email: training[X]@opsta.net
sources:
  - https://git.demo.opsta.co.th/cdb22/training[X]/ratings.git
```

* `mkdir -p ~/ratings/k8s/helm/templates` to create directory for Helm Templates
* Move our ratings manifest file to template directory with command `mv ~/ratings/k8s/ratings-*.yaml ~/ratings/k8s/helm/templates/`
* Let's try deploy Ratings Service

```bash
cd ~/ratings/

# Deploy Ratings Helm Chart
helm install bookinfo-dev-ratings k8s/helm

# Get Status
kubectl get deployment,pod,service,ingress
```

* Try to access <https://bookinfo.dev.opsta.co.th/training[X]/ratings/health> and <https://bookinfo.dev.opsta.co.th/training[X]/ratings/ratings/1> to check the deployment

## Create Helm Value file for Ratings Service

* Create `values-bookinfo-dev-ratings.yaml` file inside `k8s/helm-values` directory and put below content

```yaml
ratings:
  namespace: training[X]-bookinfo-dev
  replicas: 1
  imagePullSecrets: registry-bookinfo
  port: 8080
  image: registry.demo.opsta.co.th/training[X]/bookinfo/ratings
  tag: dev
ingress:
  host: bookinfo.dev.opsta.co.th
  path: "/training[X]/ratings(/|$)(.*)"
  serviceType: ClusterIP
  ingressClassName: nginx
  tlsSecretName: bookinfo-secret
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
    cert-manager.io/cluster-issuer: letsencrypt-prod
extraEnv:
  SERVICE_VERSION: v2
  MONGO_DB_URL: mongodb://bookinfo-dev-ratings-mongodb:27017/ratings
  MONGO_DB_USERNAME: ratings
extraEnvSecret:
  MONGO_DB_PASSWORD:
    bookinfo-dev-ratings-mongodb-secret: mongodb-passwords
```

* Let's replace variable one-by-one with these object
  * `{{ .Release.Name }}`
  * `{{ .Values.ratings.* }}`
  * `{{ .Values.ingress.* }}`
* This is sample syntax to have default value

```yaml
{{ .Values.ingress.path | default "/" }}
```

* This is sample syntax of using if and range to assign annotation

```yaml
  {{- if .Values.ingress.annotations }}
  annotations:
    {{- range $key, $value := .Values.ingress.annotations }}
    {{ $key }}: {{ $value | quote }}
    {{- end }}
  {{- end }}
```

* This is a complexity sample of using if and range syntax

```yaml
        {{- if or (.Values.extraEnv) (.Values.extraEnvSecret) }}
        env:

        {{- if .Values.extraEnv }}
        {{- range $key, $value := .Values.extraEnv }}
        - name: {{ $key }}
          value: {{ $value | quote }}
        {{- end }}
        {{- end }}

        {{- if .Values.extraEnvSecret }}
        {{- range $key, $value := .Values.extraEnvSecret }}
        {{- range $secretName, $secretValue := $value }}
        - name: {{ $key }}
          valueFrom:
            secretKeyRef:
              name: {{ $secretName }}
              key: {{ $secretValue | quote }}
        {{- end }}
        {{- end }}
        {{- end }}

        {{- end }}
```

* After replace, you can upgrade release with below command

```bash
helm upgrade -f k8s/helm-values/values-bookinfo-dev-ratings.yaml \
  bookinfo-dev-ratings k8s/helm
```

* Commit and push code to Git

## Exercise

### Exercise 1

* Create Helm value and deploy Rating service for UAT and Production environment
* Create namespaces
  * `training[X]-bookinfo-uat`
  * `training[X]-bookinfo-prd`
* Deploy MongoDB for each namespace
* Prepare Docker Image for each tag
  * registry.demo.opsta.co.th/training[X]/bookinfo/ratings:uat
  * registry.demo.opsta.co.th/training[X]/bookinfo/ratings:prd
* Create Helm value file for ratings service for each environment
  * k8s/helm-values/values-bookinfo-uat-ratings.yaml
  * k8s/helm-values/values-bookinfo-prd-ratings.yaml
* Deploy bookinfo on each environment and test it
  * <https://bookinfo.uat.opsta.co.th/training[X]/ratings/ratings/1>
  * <https://bookinfo.opsta.co.th/training[X]/ratings/ratings/1>
* Commit, push, and tag ratings service repository as `1.0.0`

### Hint

1. Create Helm Value for UAT environment
2. Build Docker Image for Ratings Service UAT environment and push to Nexus

```bash
docker compose build
docker tag registry.demo.opsta.co.th/training[X]/bookinfo/ratings:dev registry.demo.opsta.co.th/training[X]/bookinfo/ratings:uat
docker push registry.demo.opsta.co.th/training[X]/bookinfo/ratings:uat
```

3. Create namespace for UAT environment
4. Set default namespace (set-context) to UAT environment
5. Create imagePullSecrets secret
6. Create MongoDB password secret
7. Create MongoDB initdb configmap
8. Deploy MongoDB with Helm Chart
9. Deploy Ratings Service with Helm Chart

### Exercise 2

* Use `dev` branch
* Create Kubernetes & Helm deployment for `details` service
* Deploy `details` service on 3 environments on each namespaces
* There is no database for `details` service
* Tag `details` service repository as `1.0.0`

### Exercise 3

* Use `dev` branch
* Create Kubernetes & Helm deployment for `reviews` service
* Deploy `reviews` service on 3 environments on each namespaces
* There is no database for `reviews` service
* Tag `reviews` service repository as `1.0.0`

### Exercise 4

* Use `dev` branch
* Create Kubernetes & Helm deployment for `productpage` service
* Deploy `productpage` service on 3 environments on each namespaces
* There is no database for `productpage` service
* Tag `productpage` service repository as `1.0.0`

## Navigation

* Previous: [Deploy MongoDB with Helm Chart Workshop](06-helm-mongodb.md)
* [Home](../README.md)
* Next: [CI/CD with GitLab CI Workshop](08-gitlab-cicd.md)
