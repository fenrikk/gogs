pipeline {
    agent any
    stages {
        stage('Test and Coverage') {
            agent {
                docker {
                    image 'golang:1.21'
                    args '--privileged -u root'
                }
            }
            steps {
                sh 'go test -v -race ./...'
                sh 'go test -coverprofile=coverage.out ./...'
                sh 'go tool cover -html=coverage.out -o coverage.html'
                sh 'go test -bench=. ./...'
                sh 'test -z $(gofmt -l .)'
                sh 'go vet ./...'
            }
            post {
                always {
                    archiveArtifacts artifacts: 'coverage.html', allowEmptyArchive: true
                }
                failure {
                    error 'Test stage failed'
                }
            }
        }
        stage('Build and Push Docker Image') {
            agent {
                docker { 
                    image 'docker:dind' 
                    args '--privileged -u root'
                }
            }
            steps {
                script {
                    sh 'git config --global --add safe.directory "${WORKSPACE}"'
                    def commitHash = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    sh 'dockerd &'
                    def customImage = docker.build("gogs:${commitHash}")
                    sh 'apk add --no-cache aws-cli'
                    withAWS(credentials: 'ecr-admin', region: "${AWS_REGION}") {
                        sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO}"
                        sh "docker tag gogs:${commitHash} ${ECR_REPO}:${commitHash}"
                        sh "docker push ${ECR_REPO}:${commitHash}"
                    }
                }
            }
        }
    }
    post {
        always {
            script {
                cleanWs()
            }
        }
    }
}
