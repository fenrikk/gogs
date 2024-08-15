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
        
        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'SonarScanner'
                    withSonarQubeEnv('SonarQube') {
                        withCredentials([string(credentialsId: 'sonarqube-token', variable: 'SONAR_TOKEN')]) {
                            sh "${scannerHome}/bin/sonar-scanner"
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
                archiveArtifacts artifacts: "gogs-${env.COMMIT_HASH}", fingerprint: true
            }
        }
        
        stage('Upload to Nexus') {
            steps {
                script {
                    def artifactName = "gogs-${env.COMMIT_HASH}"
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
                echo "Cleanup completed"
            }
        }
    }
}
