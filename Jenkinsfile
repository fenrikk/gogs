pipeline {
    agent none
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
                sh 'dockerd --insecure-registry $DOCKER_REGISTRY &'
                sh 'docker build -t $DOCKER_REGISTRY/gogs:latest .'
                sh 'docker push $DOCKER_REGISTRY/gogs:latest'
            }
        }
    }
}
