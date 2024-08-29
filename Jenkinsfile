pipeline {
    agent {
        docker {
            image 'docker:dind'
        }
    }
    environment {
        COMMIT_HASH = sh(script: 'git rev-parse --short=7 HEAD', returnStdout: true).trim()
    }
    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}:${COMMIT_HASH}")
                    docker.build("${DOCKER_IMAGE}:latest")
                }
            }
        }
    }
    
    post {
        always {
            script {
                cleanWs()
                sh "docker rmi ${DOCKER_IMAGE}:${COMMIT_HASH} ${DOCKER_IMAGE}:latest || true"
                echo "Cleanup completed"
            }
        }
    }
}
