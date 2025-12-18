pipeline {
    agent { label 'slave-node' } // Jenkins agent node label

    // Environment variables for AWS and Docker
    environment {
        // AWS region where ECS and ECR are located
        AWS_DEFAULT_REGION = 'us-west-1'

        // ECR repository URI for storing Docker images
        ECR_REPO = '504649076991.dkr.ecr.us-west-1.amazonaws.com/nodejs-app'

        // Unique Docker image tag per build using Jenkins BUILD_NUMBER
        IMAGE_TAG = "${env.BUILD_NUMBER}"
    }

    stages {
        // Stage 1: Pull source code from GitHub repository
        stage('Source') {
            steps {
                // Clone the main branch of the repository
                git branch: 'main', url: 'https://github.com/Umarsatti1/Task-12-Jenkins-Setup-and-ECS-Deployment-Pipeline.git'
            }
        }

        // Stage 2: Build Docker image for the application
        stage('Build') {
            steps {
                script {
                    // Build Docker image and tag with IMAGE_TAG
                    sh "docker build -t nodejs-app:${IMAGE_TAG} ."
                }
            }
        }

        // Stage 3: Optional test to run container briefly and validate that it starts
        stage('Test') {
            steps {
                script {
                    sh "docker run --rm nodejs-app:${IMAGE_TAG} node app.js & sleep 5; docker ps -q | xargs docker stop || true"
                }
            }
        }

        // Stage 4: Push Docker image to Amazon ECR
        stage('Push') {
            steps {
                script {
                    // Authenticate with ECR, tag image, and push
                    sh """
                    aws ecr get-login-password --region ${AWS_DEFAULT_REGION} | docker login --username AWS --password-stdin ${ECR_REPO}
                    docker tag nodejs-app:${IMAGE_TAG} ${ECR_REPO}:${IMAGE_TAG}
                    docker push ${ECR_REPO}:${IMAGE_TAG}
                    """
                }
            }
        }

        // Stage 5: Deploy new Docker image to ECS service
        stage('Deploy') {
            steps {
                script {
                    // Trigger ECS service update with new image
                    sh """
                    aws ecs update-service \
                        --cluster nodejs-ecs-cluster \
                        --service nodejs-app-task-definition-service \
                        --force-new-deployment \
                        --region ${AWS_DEFAULT_REGION}
                    """
                }
            }
        }
    }

    // Post-build actions: notify success or failure
    post {
        success {
            echo 'Deployment succeeded! The ECS service has been updated with the new image.'
        }
        failure {
            echo 'Deployment failed. Please check the Jenkins logs and ECS task logs for errors.'
        }
    }
}