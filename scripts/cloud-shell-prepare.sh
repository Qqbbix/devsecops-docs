#!/bin/sh

# Generate SSH
[[ ! -f ~/.ssh/id_rsa ]] && ssh-keygen -f ~/.ssh/id_rsa -N ""

# Install Docker Compose v2
if [ ! -f "$HOME/.docker/cli-plugins/docker-compose" ]
then
  mkdir -p ~/.docker/cli-plugins/
  curl -SL https://github.com/docker/compose/releases/download/v2.2.3/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
  chmod +x ~/.docker/cli-plugins/docker-compose
  docker compose version
fi

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
helm version

# Install Grype
curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | sudo sh -s -- -b /usr/local/bin

# Install Syft
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sudo sh -s -- -b /usr/local/bin

# Put Bash Completion into .bashrc file
if ! grep -q 'kubectl completion bash' ~/.bashrc
then
  tee -a ~/.bashrc > /dev/null <<EOT
if command -v grype &> /dev/null
then
  # Bash Completion
  . <(kubectl completion bash)
  . <(helm completion bash)
  . <(grype completion bash)
fi
EOT
fi
