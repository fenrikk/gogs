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
                    sh 'rm -f ~/.dockercfg ~/.docker/config.json || true'
                    docker.withRegistry("https://${DOCKER_REGISTRY}", 'ecr:eu-north-1:ecr-admin') {
                        def customImage = docker.build("gogs:${commitHash}")
                        customImage.push()
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
