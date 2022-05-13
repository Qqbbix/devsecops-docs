# CDG DevSecOps Bootcamp

This tutorial walks you through setting up DevSecOps Flow.

See [Slide](https://bit.ly/opsta-cdb22) here

## Copyright

Opsta (Thailand) Co.,Ltd.

## DevSecOps Tools Details

| Tools           | Description                                                                                                                                                                                                             |
|-----------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Reserved Users  | [Please reserve your user here](https://docs.google.com/spreadsheets/d/1QNWoSPmDYkMkvKoWmZLsNpdykiK3EuszGoqzbZgDdgA)                                                                                                                    |
| GitLab          | <https://git.demo.opsta.co.th><br/>user: training[X]<br/>pass: OpstaThailand                                                                                                                   |
| Nexus           | <https://nexus.demo.opsta.co.th> for Artifacts Server<br/><https://registry.demo.opsta.co.th> for Docker Private Registry<br/>user: bookinfo<br/>Pass: OpstaThailand                                                    |
| Sonarqube       | <https://sonarqube.demo.opsta.co.th><br/>user: bookinfo<br/>pass: OpstaThailand                                                                                                                                         |
| Cloud Shell     | <https://ssh.cloud.google.com><br/>user: training[X]@opsta.net<br/>pass: OpstaThailand                                                                                                                              |
| Bookinfo Domain | <http://bookinfo.opsta.co.th/training[X]/productpage><br/><http://bookinfo.opsta.co.th/training[X]/reviews><br/><http://bookinfo.opsta.co.th/training[X]/details><br/><http://bookinfo.opsta.co.th/training[X]/ratings> |

## Workshop

This tutorial assumes you have all the DevOps Tools installed and running (GitLab, GitLab CI/CD, Nexus, SonarQube, Kubernetes Cluster) and know about how Bookinfo Application working.

* [Prerequisites](docs/01-prerequisites.md)
* [Local Development Preparation](docs/02-preparation.md)
* [Kubernetes Command Line Workshop](docs/03-k8s-cli.md)
* [Kubernetes Manifest File Workshop](docs/04-k8s-manifest.md)
* [Deploy Bookinfo Rating Service on Kubernetes Workshop](docs/05-k8s-rating.md)
* [Deploy MongoDB with Helm Chart Workshop](docs/06-helm-mongodb.md)
* [Deploy Rating Service with Helm Chart](docs/07-helm-rating.md)
* [CI/CD with GitLab Workshop](docs/08-gitlab-cicd.md)
* [Production Deployment with GitLab Workshop](docs/09-gitlab-cicd-prd.md)
* [Automation Security Workshop](docs/10-automation-security.md)
* [Container & Kubernetes Security Workshop](docs/11-container-k8s-security.md)
