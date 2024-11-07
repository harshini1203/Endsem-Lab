tools {
    maven 'Maven3'
    jdk 'JDK17'
}
pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'my-app'
        DOCKER_REGISTRY = 'your-registry'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build and Test') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}-builder", "--target builder .")
                    
                    // Run tests
                    sh "docker run --rm ${DOCKER_IMAGE}-builder mvn test"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def mavenProfile = ''
                    def imageTag = ''
                    
                    if (env.BRANCH_NAME == 'main') {
                        mavenProfile = 'production'
                        imageTag = 'production'
                    } else if (env.BRANCH_NAME == 'staging') {
                        mavenProfile = 'staging'
                        imageTag = 'staging'
                    }

                    docker.build("${DOCKER_IMAGE}:${imageTag}", "--build-arg MAVEN_PROFILE=${mavenProfile} .")
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'main') {
                        // Deploy to production
                        sh """
                            docker stop prod-app || true
                            docker rm prod-app || true
                            docker run -d --name prod-app -p 8080:8080 ${DOCKER_IMAGE}:production
                        """
                    } else if (env.BRANCH_NAME == 'staging') {
                        // Deploy to staging
                        sh """
                            docker stop staging-app || true
                            docker rm staging-app || true
                            docker run -d --name staging-app -p 8081:8080 ${DOCKER_IMAGE}:staging
                        """
                    }
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                script {
                    def port = env.BRANCH_NAME == 'main' ? '8080' : '8081'
                    
                    // Wait for application to start
                    sleep(time: 30, unit: 'SECONDS')
                    
                    // Simple health check
                    sh "curl -f http://localhost:${port}/health || exit 1"
                }
            }
        }
    }
}