pipeline {
    agent any
    stages {
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
                        sh "docker tag gogs:${commitHash} ${ECR_REPO}:latest"
                        sh "docker push ${ECR_REPO}:latest"
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
