# Production Deployment with GitLab Workshop

## Create Tagging Pipeline

* Append `.gitlab-ci.yml`

```yaml
...
tagging:
  stage: build
  image:
    name: gcr.io/go-containerregistry/crane:debug
    entrypoint: [""]
  script:
    - crane auth login -u ${OPSTA_NEXUS_REGISTRY_USER} -p ${OPSTA_NEXUS_REGISTRY_PASSWORD} ${OPSTA_NEXUS_REGISTRY}
    - crane cp ${IMAGE_NAME}:uat ${IMAGE_NAME}:${CI_COMMIT_TAG}
  variables:
    GIT_STRATEGY: none
  only:
    - tags
  except:
    - web
```

> Read more about crane at <https://github.com/google/go-containerregistry>

* Push to `dev` branch and doing merge request to `main` branch
* To trigger tagging pipeline
  * Go to <https://git.demo.opsta.co.th/cdb22/training[X]/ratings/-/tags> or go to your repository > `Repository` > `Tags` and click on `New tag` button
  * Tag name: v1.0.0
  * Create tag
* Check your GitLab Pipelines
* When finished, go check your Docker Image at <https://nexus.demo.opsta.co.th/#browse/browse:docker-registry-private> to see new tag

## Create Ratings Service Deploy to Production Pipeline

* Replace `workflow:` on `.gitlab-ci.yml` with the following

```yaml
workflow:
  rules:
    - if: $CI_COMMIT_BRANCH == "main"
      variables:
        ENV_NAME: uat
        IMAGE_TAG: $ENV_NAME
        ENV_URL: https://bookinfo.$ENV_NAME.opsta.co.th/training[X]/ratings
    - if: $CI_PIPELINE_SOURCE == "web" && $CI_COMMIT_TAG
      variables:
        ENV_NAME: prd
        IMAGE_TAG: $CI_COMMIT_TAG
        ENV_URL: https://bookinfo.opsta.co.th/training[X]/ratings
    - variables:
        ENV_NAME: $CI_COMMIT_BRANCH
        IMAGE_TAG: $ENV_NAME
        ENV_URL: https://bookinfo.$ENV_NAME.opsta.co.th/training[X]/ratings
```

* Replace `deploy:` job with the following

```yaml
deploy:
  stage: deploy
  image:
    name: scholarshipowl/gcloud-helm-ko:latest
    entrypoint: [""]
  script: 
    - /docker-entrypoint.sh
    - helm upgrade --install -f k8s/helm-values/values-bookinfo-${ENV_NAME}-ratings.yaml --wait
      --set ratings.tag=${IMAGE_TAG}
      --set extraEnv.COMMIT_SHA=${CI_COMMIT_SHORT_SHA}
      --namespace training[X]-bookinfo-${ENV_NAME} bookinfo-${ENV_NAME}-ratings k8s/helm
  only:
    - dev
    - main
    - web
```

* Don't forget to add `- web` on `acceptance-test:` job
* Push to `dev` branch and doing merge request to `main` branch
* Tag to version `v1.0.1`
* To manual run deploy to production workflow
  * Go to <https://git.demo.opsta.co.th/cdb22/training[X]/ratings/-/pipelines> or go to your repository > `CI/CD` > `Pipelines` and click on `Run pipeline` button
  * Choose your tagging version on `Run for branch name or tag` and click on `Run pipeline` to make GitLab CI/CD run deploy to production pipeline
* Check result at <https://bookinfo.opsta.co.th/training[X]/ratings/health> and <https://bookinfo.opsta.co.th/training[X]/ratings/ratings/1>

## Assignment

### Assignment 1

* Create GitLab CI/CD for `details` service
* Deploy `details` service with GitLab CI/CD on 3 environments on each namespaces
  * `training[X]-bookinfo-dev`
  * `training[X]-bookinfo-uat`
  * `training[X]-bookinfo-prd`
* Tag `details` service repository as `v1.0.0`

### Assignment 2

* Create GitLab CI/CD for `reviews` service
* Deploy `reviews` service with GitLab CI/CD on 3 environments on each namespaces
  * `training[X]-bookinfo-dev`
  * `training[X]-bookinfo-uat`
  * `training[X]-bookinfo-prd`
* Tag `reviews` service repository as `v1.0.0`

### Assignment 3

* Create GitLab CI/CD for `productpage` service
* Deploy `productpage` service with GitLab CI/CD on 3 environments on each namespaces
  * `training[X]-bookinfo-dev`
  * `training[X]-bookinfo-uat`
  * `training[X]-bookinfo-prd`
* Tag `productpage` service repository as `v1.0.0`

## Navigation

* Previous: [CI/CD with GitLab Workshop](08-gitlab-cicd.md)
* [Home](../README.md)
* Next: [Automation Security Workshop](10-automation-security.md)
