# Prerequisites

## All-in-one preparation command

```bash
curl -s https://gist.githubusercontent.com/winggundamth/2d974fd0f5429bd65e89107edbad3810/raw/a300bfd38ea3666e3e830aac6a81e05c555a3bb2/cloud-shell-prepare.sh | bash

# Exit shell and reopen terminal to get bash completion
exit
```

## Prepare SSH key

* Put this command to generate your SSH key

```bash
ssh-keygen -f ~/.ssh/id_rsa -N ""
```

> You will have your SSH private and public key in `~/.ssh/` directory

## Install Docker Compose

```bash
mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.5.0/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose
docker compose version
```

## Install Helm

```bash
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
helm version
```

## Install Grype

```bash
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sudo sh -s -- -b /usr/local/bin
```

## Install Syft

```bash
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/local/bin
```

## Install Trivy

```bash
sudo apt-get install wget apt-transport-https gnupg lsb-release
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
echo deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy
```

## Reset Cloud Shell

In case your Cloud Shell having problem and you want to remove all the data to reset Cloud Shell

* Put this command to remove all the files in your $HOME directory

```bash
sudo rm -rf $HOME
```

* Click on `vertical three dot` icon on the top right for more menu and choose `Restart`

## Navigation

* [Home](../README.md)
* Next: [Local Development Preparation](02-preparation.md)
