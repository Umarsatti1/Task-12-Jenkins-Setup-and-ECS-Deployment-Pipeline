pipeline {
    agent { label 'slave-node' } // Jenkins agent node label

    // Environment variables for AWS and Docker
    environment {
        // AWS region where ECS and ECR are located
        AWS_DEFAULT_REGION = 'us-west-1'

        // ECR repository URI for storing Docker images
        ECR_REPO = '504649076991.dkr.ecr.us-west-1.amazonaws.com/nodejs-app'

        // Use "latest" tag for Docker image
        IMAGE_TAG = "latest"
    }

    stages {
        // Stage 1: Pull source code from GitHub repository
        stage('Source') {
            steps {
                git branch: 'main', url: 'https://github.com/Umarsatti1/Task-12-Jenkins-Setup-and-ECS-Deployment-Pipeline.git'
            }
        }

        // Stage 2: Build Docker image for the application
        stage('Build') {
            steps {
                script {
                    sh "docker build -t nodejs-app:${IMAGE_TAG} ."
                }
            }
        }

        // Stage 3: Optional test to run container briefly
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
            echo 'Deployment succeeded! ECS service has been updated with the latest image.'
        }
        failure {
            echo 'Deployment failed. Please check Jenkins and ECS logs for errors.'
        }
    }
}