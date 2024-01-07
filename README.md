### JFROG ARTIFACTORY

- https://docker.bintray.io/ui/artifactSearchResults?name=artifactory-oss&type=artifacts
- https://jfrog.com/help/r/jfrog-installation-setup-documentation/install-artifactory-single-node-with-docker?section=UUID-999fbbd5-ed0b-361e-e622-5bf2bc159060_UUID-6560a094-94c2-ca03-359f-ccb55be0e480

- default user: admin
- default password: password

- logs of artifactory
```bash
docker logs -f artifactory 
```

- terraform backend
```bash
aws s3api create-bucket --bucket terraform-cloudgeeks --region us-east-1
aws s3api put-bucket-versioning --bucket terraform-cloudgeeks --versioning-configuration Status=Enabled 
```

- base64 encode
```bash
cat jfrog.sh | base64 -w 0
cat jfrog.sh | base64 -w 0 > jfrog.base64

cat jenkins.sh | base64 -w 0
cat jenkins.sh | base64 -w 0 > jenkins.base64
```