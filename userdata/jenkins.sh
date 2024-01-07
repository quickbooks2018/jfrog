#!/bin/bash
apt update -y

# Docker Installation
curl -fsSL https://get.docker.com -o install-docker.sh
sh install-docker.sh

# Docker run Jenkins
docker network create jenkins --attachable
docker run --name jenkins --network jenkins -w /var/jenkins_home -id -v jenkins:/var/jenkins_home -p 8080:8080 -v $(which docker):/usr/bin/docker -v /var/run/docker.sock:/var/run/docker.sock --restart unless-stopped jenkins/jenkins:lts

# End of Script