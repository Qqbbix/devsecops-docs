# CI/CD with GitLab Workshop

## Preparation

* Make sure to commit your latest `bookinfo-ratings` on Google Cloud Shell to your GitLab Repository `dev` branch

## Create GitLab CI Pipeline

* Try first our GitLab Pipeline

```bash
cd ~/ratings/
touch .gitlab-ci.yml
```

> **_NOTE:_** View > Toggle Hidden Files

```yaml
stages:
  - build

image: alpine

build:
  stage: build
  script:
    - ls -l
    - echo "CI_PROJECT_DIR = ${CI_PROJECT_DIR} ${OPSTA_NEXUS_REGISTRY}"
    - echo "OPSTA_NEXUS_REGISTRY = ${OPSTA_NEXUS_REGISTRY}"
  only:
  - dev
```

* Git commit and push
* Check result at <https://git.demo.opsta.co.th/cdb22/training[X]/ratings/-/pipelines>

## Create CI by build and push Docker Image

```yaml
stages:
  - build

build:
  stage: build
  image:
    name: gcr.io/kaniko-project/executor:debug
    entrypoint: [""]
  script:
    # Authen with Docker Registry first
    - mkdir -p /kaniko/.docker
    - echo "{\"auths\":{\"${OPSTA_NEXUS_REGISTRY}\":{\"auth\":\"$(printf "%s:%s" "${OPSTA_NEXUS_REGISTRY_USER}" "${OPSTA_NEXUS_REGISTRY_PASSWORD}" | base64 | tr -d '\n')\"}}}" > /kaniko/.docker/config.json
    # Run Kaniko build and push Docker Image
    - /kaniko/executor
      --context "${CI_PROJECT_DIR}"
      --dockerfile "${CI_PROJECT_DIR}/Dockerfile"
      --destination "registry.demo.opsta.co.th/training[X]/bookinfo/ratings:dev"
  only:
  - dev
```

> **_NOTE:_** See more information about Kaniko <https://github.com/GoogleContainerTools/kaniko>

## Create CD Pipeline

* Replace `.gitlab-ci.yml` with the following

```yaml
variables:
  CLOUDSDK_COMPUTE_ZONE: asia-southeast1-a
  CLOUDSDK_CORE_PROJECT: zcloud-cicd
  CLOUDSDK_CONTAINER_CLUSTER: k8s
  GOOGLE_APPLICATION_CREDENTIALS: $GCLOUD_CDB22
  IMAGE_NAME: registry.demo.opsta.co.th/training[X]/bookinfo/ratings

stages:
  - build
  - deploy

build:
  stage: build
  image:
    name: gcr.io/kaniko-project/executor:debug
    entrypoint: [""]
  script:
    # Authen with Docker Registry first
    - mkdir -p /kaniko/.docker
    - echo "{\"auths\":{\"${OPSTA_NEXUS_REGISTRY}\":{\"auth\":\"$(printf "%s:%s" "${OPSTA_NEXUS_REGISTRY_USER}" "${OPSTA_NEXUS_REGISTRY_PASSWORD}" | base64 | tr -d '\n')\"}}}" > /kaniko/.docker/config.json
    # Run Kaniko build and push Docker Image
    - /kaniko/executor
      --context "${CI_PROJECT_DIR}"
      --dockerfile "${CI_PROJECT_DIR}/Dockerfile"
      --destination "${IMAGE_NAME}:dev"
  only:
  - dev

deploy:
  stage: deploy
  image:
    name: scholarshipowl/gcloud-helm-ko:latest
    entrypoint: [""]
  script: 
    - /docker-entrypoint.sh
    - helm upgrade --install -f k8s/helm-values/values-bookinfo-dev-ratings.yaml --wait
      --namespace training[X]-bookinfo-dev bookinfo-dev-ratings k8s/helm
  only:
  - dev
```

### Test and Fix CI/CD

* Try to change source code `src/ratings.js` line 216 to `Ratings is good` instead
* Push code, check GitLab CI/CD and test health check page result
* Health check page won't update because when helm upgrade new release, everything still the same.

### Fix health check page won't update

* Add following to deploy step in `.gitlab-ci.yml`

```yaml
...
  script:
    - /docker-entrypoint.sh
    - helm upgrade --install -f k8s/helm-values/values-bookinfo-dev-ratings.yaml --wait
      --set extraEnv.COMMIT_SHA=${CI_COMMIT_SHORT_SHA}
      --namespace training[X]-bookinfo-dev bookinfo-dev-ratings k8s/helm
...
```

* Push code, check GitLab CI/CD and test health check page result again.

## Practice GitLab CI/CD

### Add Acceptance Test

* Add `acceptance-test` stage and job to do following curl command for acceptance test to see health check page is working
* Use variables for both domain and check text

```bash
curl ${ENV_URL}/health | grep "${ACCEPTANCE_TEST_TEXT}"
```

* Hint: use `curlimages/curl:7.83.0` image

### Add Deploy to UAT Environment

* Try to improve `.gitlab-ci.yml` to make it deploy UAT environment by merge request from `dev` to `main` branch
* Hint: put the following line on top of `.gitlab-ci.yml` and use `$ENV_NAME` as variable

```yaml
workflow:
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
      variables:
        ENV_NAME: uat
        ENV_URL: https://bookinfo.$ENV_NAME.opsta.co.th/training[X]/ratings
    - variables:
        ENV_NAME: $CI_COMMIT_BRANCH
        ENV_URL: https://bookinfo.$ENV_NAME.opsta.co.th/training[X]/ratings
```

> The workflow keyword is evaluated before jobs

## Navigation

* Previous: [Deploy Rating Service with Helm Chart Workshop](07-helm-rating.md)
* [Home](../README.md)
* Next: [Production Deployment with GitLab Workshop](09-gitlab-cicd-prd.md)
