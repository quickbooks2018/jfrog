### JFROG ARTIFACTORY

- https://docker.bintray.io/ui/artifactSearchResults?name=artifactory-oss&type=artifacts

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

- Step1
- https://plugins.jenkins.io/jfrog/
- Install jfrog Jenkins plugin from Jenkins UI, search artifactory plugin

- Step2
- set credentials in Jenkins username/password
- ---> configure ---> system ---> ctrl +f JFrog Plugin Configuration
- server address http://ip:8082
- http://10.60.100.187:8082/
- check allow http connection

- In jenkins Jfrog-cli you will find in tools

- Sample pipeline
```bash
pipeline {
    agent any
    tools {
        jfrog 'jfrog-cli'
    }
    stages {
        stage('Testing') {
            steps {
                // Show the installed version of JFrog CLI.
                jf '-v'

                // Show the configured JFrog Platform instances.
                jf 'c show'

                // Ping Artifactory.
                jf 'rt ping'

                // Create a file and upload it to a repository named 'example-repo-local' in Artifactory
                sh 'touch test-file'
                jf 'rt u test-file example-repo-local/'

                // Publish the build-info to Artifactory.
                jf 'rt bp'

                // Download the test-file
                jf 'rt dl example-repo-local/test-file'
            }
        }
    }
}
```

- Jfrog cli installation
```bash
# Download the JFrog CLI binary
wget -qO jfrog https://releases.jfrog.io/artifactory/jfrog-cli/v2/[RELEASE]/jfrog-cli-linux-amd64/jfrog

# Make the binary executable
chmod +x jfrog

# Move it to a system path
mv jfrog /usr/local/bin/ 
```
