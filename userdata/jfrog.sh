#!/bin/bash
apt update -y

# Docker Installation
curl -fsSL https://get.docker.com -o install-docker.sh
sh install-docker.sh

# Downloading JFrog Artifactory
curl -o docker-compose.yaml https://raw.githubusercontent.com/quickbooks2018/jfrog/main/docker-compose.yaml

docker compose up -d

# End of Script