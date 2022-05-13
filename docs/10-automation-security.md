# Automation Security Workshop

## SAST

### Run SonarQube on Command Line

```bash
cd ~/ratings/
docker run --rm -v "$PWD:/usr/src" \
  -e SONAR_HOST_URL="https://sonarqube.demo.opsta.co.th" \
  sonarsource/sonar-scanner-cli:4.7.0 \
  -D sonar.projectKey=$USER-bookinfo-ratings \
  -D sonar.projectName=$USER-bookinfo-ratings \
  -D sonar.sources=./src \
  -D sonar.login=bookinfo \
  -D sonar.password=CHANGEME
sudo rm -rf .scannerwork
```

* Login to <https://sonarqube.demo.opsta.co.th> with provided credential to see result

### Add SonarQube Scanner to GitLab CI

* Add `security` stage in `.gitlab-ci.yml` file

```yaml
stages:
  - build
  - security
  - deploy
  - acceptance-test
```

* Add GitLab CI/CD Variables at <https://git.demo.opsta.co.th/cdb22/training[X]/ratings/-/settings/ci_cd> or go to your repository > `Settings` > `CI/CD`
* `Expand` Variables
* Add the following variables
  * SONAR_HOST_URL: https://sonarqube.demo.opsta.co.th
  * SONAR_LOGIN: bookinfo
  * SONAR_PASSWORD: OpstaThailand (Masked)
  * SONAR_USER_PROJECT: training[X]
* Append `.gitlab-ci.yml`

```yaml
...
sonarqube:
  stage: security
  image:
    name: sonarsource/sonar-scanner-cli:4.7.0
    entrypoint: [""]
  script:
    - sonar-scanner
      -D sonar.qualitygate.wait=true
      -D sonar.projectKey=${SONAR_USER_PROJECT}-bookinfo-ratings
      -D sonar.projectName=${SONAR_USER_PROJECT}-bookinfo-ratings
      -D sonar.projectVersion=${ENV_NAME}-${CI_JOB_ID}
      -D sonar.sources=./src
      -D sonar.login=${SONAR_LOGIN}
      -D sonar.password=${SONAR_PASSWORD}
  # allow_failure: true
  only:
    - dev
    - main
```

* Commit and push updated `.gitlab-ci.yml`
* See the result in GitLab CI/CD Pipeline that it won't pass Quality Gate

### Fix SonarQube Quality Gate

* Insert `var random;` on line 180
* Replace 2 places for

```javascript
        var random = Math.random(); // returns [0,1]
```

* with

```javascript
        const crypto = require('crypto');
        random = crypto.randomBytes(4).readUInt32LE() / 0xffffffff; // returns [0,1]
```

* Git commit and push to see the SonarQube Gate Quality passes

## SCA

### Add OWASP Dependency Check to GitLab CI/CD

* <https://github.com/jeremylong/DependencyCheck>
* Append `.gitlab-ci.yml`

```yaml
...
owasp_dependency_check:
  stage: security
  image:
    name: registry.gitlab.com/gitlab-ci-utils/docker-dependency-check:1.13.0
    entrypoint: [""]
  script:
    # Job will scan the project root folder and fail if any vulnerabilities with CVSS > 0 are found
    - /usr/share/dependency-check/bin/dependency-check.sh --scan "./" --format ALL --project "$CI_PROJECT_NAME" --failOnCVSS 0
    # Dependency Check will only fail the job based on CVSS scores, and in some cases vulnerabilities do not
    # have CVSS scores (e.g. those from NPM audit), so they don't cause failure. To fail for any vulnerabilities
    # grep the resulting report for any "vulnerabilities" sections and exit if any are found (count > 0).
    - if [ $(grep -c "vulnerabilities" dependency-check-report.json) -gt 0 ]; then exit 2; fi
  # allow_failure: true
  cache:
    paths:
      - /usr/share/dependency-check/data
  artifacts:
    when: always
    expire_in: 1 week
    paths:
        # Save the HTML and JSON report artifacts
      - "./dependency-check-report.html"
      - "./dependency-check-report.json"
  only:
    - dev
    - main
```

* Commit and push updated `.gitlab-ci.yml`
* See the result in GitLab CI/CD Pipeline. You can download pipeline artifact to see the report.

## Docker Image Security

### Syft

* <https://github.com/anchore/syft>
* CLI tool and library for generating a Software Bill of Materials from container images and filesystems

```bash
syft registry.demo.opsta.co.th/training[X]/bookinfo/ratings:dev
```

> This many times it won't accurate

### Grype

* <https://github.com/anchore/grype>
* A vulnerability scanner for container images and filesystems

```bash
grype db update
grype registry.demo.opsta.co.th/training[X]/bookinfo/ratings:dev
```

> This many times it won't accurate

### Trivy

* <https://aquasecurity.github.io/trivy>

```bash
trivy image registry.demo.opsta.co.th/training[X]/bookinfo/ratings:dev
```

### Add Trivy to GitLab CI/CD

* Append `.gitlab-ci.yml`

```yaml
...
trivy:
  stage: security
  image:
    name: aquasec/trivy:0.27.1
    entrypoint: [""]
  variables:
    # No need to clone the repo, we exclusively work on artifacts.  See
    # https://docs.gitlab.com/ee/ci/runners/README.html#git-strategy
    GIT_STRATEGY: none
    TRIVY_USERNAME: $OPSTA_NEXUS_REGISTRY_USER
    TRIVY_PASSWORD: $OPSTA_NEXUS_REGISTRY_PASSWORD
    TRIVY_AUTH_URL: $OPSTA_NEXUS_REGISTRY
    FULL_IMAGE_NAME: $IMAGE_NAME:$ENV_NAME
  script:
    - trivy --version
    # cache cleanup is needed when scanning images with the same tags, it does not remove the database
    - time trivy image --clear-cache
    # update vulnerabilities db
    - time trivy image --download-db-only --no-progress
    # Builds report and puts it in the default workdir $CI_PROJECT_DIR, so `artifacts:` can take it from there
    - time trivy image --exit-code 0 --no-progress --format template --template "@/contrib/gitlab.tpl"
        --output "$CI_PROJECT_DIR/gl-container-scanning-report.json" "$FULL_IMAGE_NAME"
    # Prints full report
    - time trivy image --exit-code 0 --no-progress "$FULL_IMAGE_NAME"
    # Fail on critical vulnerabilities
    - time trivy image --exit-code 1 --severity CRITICAL --no-progress "$FULL_IMAGE_NAME"
  cache:
    paths:
      - .cache/trivy/
  # Enables https://docs.gitlab.com/ee/user/application_security/container_scanning/ (Container Scanning report is available on GitLab EE Ultimate or GitLab.com Gold)
  artifacts:
    when: always
    expire_in: 1 week
    reports:
      container_scanning: gl-container-scanning-report.json
  only:
    - dev
    - main
```

* Commit and push updated `.gitlab-ci.yml`
* See the result in GitLab CI/CD Pipeline. You can download pipeline artifact to see the report.

## Infrastructure as Code Security

### kubesec

* <https://kubesec.io>
* Security risk analysis for Kubernetes resources

```bash
cd ~/ratings/
helm template -f k8s/helm-values/values-bookinfo-dev-ratings.yaml bookinfo-dev-ratings k8s/helm | docker run -i --rm kubesec/kubesec:v2.11.4 scan /dev/stdin
```

* See the result from output

### sKan

* <https://github.com/alcideio/skan>
* Scan Kubernetes resource files and helm charts for security configurations issues and best practices.

```bash
helm template -f k8s/helm-values/values-bookinfo-dev-ratings.yaml \
  bookinfo-dev-ratings k8s/helm | \
  docker run -i --rm -v $(pwd)/result:/result alcide/skan:v0.9.0 \
  manifest --outputfile /result/skan-result.html -f -
# Try to download skan-result.html and open on your laptop
sudo rm -rf result
```

### Add sKan to GitLab CI/CD

* Append `.gitlab-ci.yml`

```yaml
...
helm-template:
  stage: build
  image:
    name: scholarshipowl/gcloud-helm-ko:latest
    entrypoint: [""]
  script:
    - >-
      helm template -f k8s/helm-values/values-bookinfo-${ENV_NAME}-ratings.yaml
      --set extraEnv.COMMIT_SHA=${CI_COMMIT_SHORT_SHA}
      --namespace training[X]-bookinfo-${ENV_NAME} bookinfo-${ENV_NAME}-ratings k8s/helm
      > k8s-manifest-deploy.yaml
  artifacts:
    when: always
    expire_in: 10 mins
    paths:
      - "./k8s-manifest-deploy.yaml"
  only:
    - dev
    - main

skan:
  stage: security
  dependencies:
    - helm-template
  image:
    name: alcide/skan:v0.9.0-debug
    entrypoint: [""]
  script:
    - /skan manifest -f k8s-manifest-deploy.yaml
  artifacts:
    when: always
    expire_in: 1 week
    paths:
      - "./skan-result.html"
  only:
    - dev
    - main
```

* Commit and push updated `.gitlab-ci.yml`
* See the result in GitLab CI/CD Pipeline. You can download pipeline artifact to see the report.

## DAST

```bash
docker run -v $(pwd):/zap/wrk/ -i owasp/zap2docker-stable:2.11.1 \
  zap-baseline.py -r baseline-report.html -l PASS \
  -t "https://bookinfo.dev.opsta.co.th"
docker run -v $(pwd):/zap/wrk/ -i owasp/zap2docker-stable:2.11.1 \
  zap-api-scan.py -r api-report.html -l PASS -f openapi \
  -t "https://bookinfo.dev.opsta.co.th/training[X]/ratings/"
docker run -v $(pwd):/zap/wrk/ -i owasp/zap2docker-stable:2.11.1 \
  zap-full-scan.py -r full-report.html -l PASS \
  -t "https://bookinfo.dev.opsta.co.th/training[X]/ratings/ratings/1"
```

## Navigation

* Previous: [Production Deployment with GitLab Workshop](09-gitlab-cicd-prd.md)
* [Home](../README.md)
* Next: [Container & Kubernetes Security Workshop](11-container-k8s-security.md)
