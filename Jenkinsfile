pipeline {
    agent any
    stages {
        stage('Build and Push Docker Image') {
            agent {
                docker { 
                    image 'dind-aws-cli:latest' 
                    args '--privileged -u root --entrypoint='''
                }
            }
            steps {
                script {
                    sh 'git config --global --add safe.directory "${WORKSPACE}"'
                    def commitHash = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    sh 'dockerd &'
                    def customImage = docker.build("gogs:${commitHash}")
                    docker.withRegistry("https://${ECR_REPO}", "ecr:${AWS_REGION}:ecr-admin") {
                        customImage.push('latest')
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
