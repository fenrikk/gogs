pipeline {
    agent {
        label "${AGENT_LABEL}"
    }
    environment {
        COMMIT_HASH = sh(script: 'git rev-parse --short=7 HEAD', returnStdout: true).trim()
    }
   stages {
        stage('Build Docker Image') {
            steps {
                withDockerTool('docker') {
                    script {
                        docker.build("${DOCKER_IMAGE}:${COMMIT_HASH}")
                        docker.build("${DOCKER_IMAGE}:latest")
                    }
                }
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

        stage('Push to Nexus') {
            steps {
                script {
                    docker.withRegistry("http://${DOCKER_REGISTRY}", "${NEXUS_CREDENTIAL_ID}") {
                        docker.image("${DOCKER_IMAGE}:${COMMIT_HASH}").push()
                        docker.image("${DOCKER_IMAGE}:latest").push()
                    }
                }
            }
        }
    }
    post {
        always {
            script {
                cleanWs()
                sh "docker rmi ${DOCKER_IMAGE}:${COMMIT_HASH} ${DOCKER_IMAGE}:latest || true"
                sh "rm -f coverage.out test-report.json coverage.html"
                echo "Cleanup completed"
            }
        }
    }
}
