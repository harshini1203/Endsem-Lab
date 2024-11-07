pipeline {
    agent any

    tools {
        maven 'Maven3'
        jdk 'JDK17'
    }

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
                    // Build Docker image with target 'builder'
                    bat 'docker build -t ${DOCKER_IMAGE}-builder --target builder .'

                    // Run tests using Maven inside Docker container
                    bat "docker run --rm ${DOCKER_IMAGE}-builder mvn test"
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

                    // Build Docker image with dynamic tag based on branch
                    bat "docker build -t ${DOCKER_IMAGE}:${imageTag} --build-arg MAVEN_PROFILE=${mavenProfile} ."
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'main') {
                        // Deploy to production using Docker on Windows
                        bat """
                            docker stop prod-app || echo 'No prod-app to stop'
                            docker rm prod-app || echo 'No prod-app to remove'
                            docker run -d --name prod-app -p 8080:8080 ${DOCKER_IMAGE}:production
                        """
                    } else if (env.BRANCH_NAME == 'staging') {
                        // Deploy to staging using Docker on Windows
                        bat """
                            docker stop staging-app || echo 'No staging-app to stop'
                            docker rm staging-app || echo 'No staging-app to remove'
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
                    
                    // Perform a health check with curl (for Windows, use curl from Git Bash or equivalent)
                    bat "curl -f http://localhost:${port}/health || exit 1"
                }
            }
        }
    }

    post {
        failure {
            echo "The pipeline has failed. Please check the logs."
        }

        success {
            echo "The pipeline completed successfully!"
        }
    }
}
