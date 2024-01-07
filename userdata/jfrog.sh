#!/bin/bash
apt update -y

# Docker Installation
curl -fsSL https://get.docker.com -o install-docker.sh
sh install-docker.sh

# Downloading JFrog Artifactory
cat <<EOF > docker-compose.yml
services:
  # https://docker.bintray.io/ui/artifactSearchResults?name=artifactory-oss&type=artifacts
  artifactory:
    image: docker.bintray.io/jfrog/artifactory-oss:latest
    container_name: artifactory
    ports:
      - "8082:8082"
    environment:
      - ARTIFACTORY_HOME=/var/opt/jfrog/artifactory
      - EXTRA_JAVA_OPTIONS=-Xms512m -Xmx4g
    volumes:
      - artifactory_data:/var/opt/jfrog/artifactory
    networks:
      - jfrog
    restart: unless-stopped

  # https://hub.docker.com/_/postgres/tags
  postgres:
    image: postgres:latest
    container_name: postgres
    environment:
      - POSTGRES_DB=artifactory
      - POSTGRES_USER=artifactory
      - POSTGRES_PASSWORD=securepassword
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - jfrog
    restart: unless-stopped

volumes:
  artifactory_data:
  postgres_data:

networks:
  jfrog:
    driver: bridge
EOF

# Starting JFrog Artifactory
docker compose up -d

# End of Script