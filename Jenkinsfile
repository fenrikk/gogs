pipeline {
    agent {
        label "${AGENT_LABEL}"
    }
    tools {
        go "${GO_VERSION}"
    }
    stages {
        stage('Build') {
            steps {
                sh "go build -o gogs-${env.GIT_COMMIT.take(7)}"
            }
        }
        
        stage('Test and Coverage') {
            steps {
                script {
                    sh 'CGO_ENABLED=1 go test -v ./... -coverprofile=coverage.out -json > test-report.json'
                    sh 'go tool cover -html=coverage.out -o coverage.html'
                }
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'SonarScanner'
                    withSonarQubeEnv('SonarQube') {
                        withCredentials([string(credentialsId: 'sonarqube-token', variable: 'SONAR_TOKEN')]) {
                            sh """
                                ${scannerHome}/bin/sonar-scanner \
                                -Dsonar.projectKey=${SONAR_PROJECT_KEY} \
                                -Dsonar.sources=. \
                                -Dsonar.exclusions=**/* \
                                -Dsonar.test.inclusions= \
                                -Dsonar.go.coverage.reportPaths=coverage.out \
                                -Dsonar.go.tests.reportPaths=test-report.json \
                                -Dsonar.coverage.exclusions=
                            """
                        }
                    }
                }
            }
        }
        
        stage('Quality Gate') {
            steps {
                waitForQualityGate abortPipeline: true, webhookSecretId: 'sonar-webhook-secret'
            }
        }
        
        stage('Archive Artifact') {
            steps {
                archiveArtifacts artifacts: "gogs-${env.GIT_COMMIT.take(7)}", fingerprint: true
            }
        }
        
        stage('Upload to Nexus') {
            steps {
                script {
                    def artifactName = "gogs-${env.GIT_COMMIT.take(7)}"
                    def latestArtifactName = "gogs-latest"
                    nexusArtifactUploader(
                        nexusVersion: 'nexus3',
                        protocol: 'http',
                        nexusUrl: "${NEXUS_URL}",
                        groupId: 'gogs-artifacts',
                        version: "${env.COMMIT_HASH}",
                        repository: "${NEXUS_REPOSITORY}",
                        credentialsId: "${NEXUS_CREDENTIAL_ID}",
                        artifacts: [
                            [artifactId: 'gogs', 
                             classifier: '', 
                             file: artifactName]
                        ]
                    )
                    sh "cp ${artifactName} ${latestArtifactName}"
                    nexusArtifactUploader(
                        nexusVersion: 'nexus3',
                        protocol: 'http',
                        nexusUrl: "${NEXUS_URL}",
                        groupId: 'gogs-artifacts',
                        version: "gogs-latest",
                        repository: "${NEXUS_REPOSITORY}",
                        credentialsId: "${NEXUS_CREDENTIAL_ID}",
                        artifacts: [
                            [artifactId: 'gogs', 
                             classifier: '', 
                             file: latestArtifactName]
                        ]
                    )
                }
            }
        }
        stage('Update Gogs') {
            steps {
                sshagent(credentials: ['ansible-ssh-key']) {
                    sh """
                        ssh ${ANSIBE_HOST_IP} "cd ${PATH_TO_UPDATE_PLAYBOOK} && \
                        ansible-playbook ${UPDATE_PLAYBOOK_NAME} \
                        -e 'gogs_version=${env.COMMIT_HASH}'"
                    """
                }
            }
        }
    }
    post {
        always {
            script {
                cleanWs()
                sh "rm -f gogs-${env.GIT_COMMIT.take(7)}"
                sh "rm -f coverage.out test-report.json coverage.html"
                echo "Cleanup completed"
            }
        }
    }
}
