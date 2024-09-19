pipeline {
    agent any
    stages {
        // stage('Test and Coverage') {
        //     agent {
        //         docker {
        //             image 'golang:1.21'
        //             args '--privileged -u root'
        //         }
        //     }
        //     steps {
        //         sh 'go test -v -race ./...'
        //         sh 'go test -coverprofile=coverage.out ./...'
        //         sh 'go tool cover -html=coverage.out -o coverage.html'
        //         sh 'go test -bench=. ./...'
        //         sh 'test -z $(gofmt -l .)'
        //         sh 'go vet ./...'
        //     }
        //     post {
        //         always {
        //             archiveArtifacts artifacts: 'coverage.html', allowEmptyArchive: true
        //         }
        //         failure {
        //             error 'Test stage failed'
        //         }
        //     }
        // }
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
                    sh 'dockerd --insecure-registry $DOCKER_REGISTRY &'
                    docker.withRegistry("https://${DOCKER_REGISTRY}", 'ecr:eu-north-1:ecr-admin') {
                        def customImage = docker.build("${DOCKER_REGISTRY}/gogs:${commitHash}")
                        customImage.push()
                        customImage.push('latest')
                    }

                    withCredentials([usernamePassword(credentialsId: 'github-credentials', usernameVariable: 'GIT_USERNAME', passwordVariable: 'GIT_PASSWORD')]) {
                        sh "git clone https://${GIT_USERNAME}:${GIT_PASSWORD}@${GIT_REPO_URL.replace('https://', '')} repo"                        
                        dir('repo') {
                            sh "sed -i 's|image: $DOCKER_REGISTRY/gogs:.*|image: $DOCKER_REGISTRY/gogs:${commitHash}|' gogs-deployment-service.yaml"
                            sh "git config user.email 'jenkins@example.com'"
                            sh "git config user.name 'Jenkins'"
                            sh "git add gogs-deployment-service.yaml"
                            sh "git commit -m 'Update Gogs image to ${commitHash}'"
                            sh "git push origin HEAD:main"
                        }
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
