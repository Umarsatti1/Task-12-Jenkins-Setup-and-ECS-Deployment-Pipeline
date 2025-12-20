# Jenkins Pipeline Setup for ECS Deployment

This project demonstrates an end-to-end CI/CD pipeline that automates the build, test, and deployment of a Dockerized Node.js application to **Amazon ECS (Fargate)** using **Jenkins**, **GitHub**, **Amazon ECR**, and **AWS CLI**. The pipeline is fully automated and triggered by GitHub pushes, enabling consistent and repeatable deployments to AWS.

---

## Architecture Diagram

<p align="center">
  <img src="./diagram/Architecture Diagram.png" alt="Architecture Diagram" width="900">
</p>

---

## Project Overview

The CI/CD workflow follows these steps:

1. Developer pushes code to GitHub  
2. GitHub webhook triggers Jenkins pipeline  
3. Jenkins Master schedules the job on a Jenkins Agent  
4. Jenkins Agent:
   - Builds the Docker image
   - Runs a basic container test
   - Pushes the image to Amazon ECR
   - Triggers an ECS service update
5. Amazon ECS pulls the latest image and performs a rolling deployment
6. Updated application is accessible via ECS task ENI IP

---

## Key AWS Services Used

- **Amazon EC2** – Hosts Jenkins Master and Jenkins Agent  
- **Amazon VPC** – Custom networking with public subnet and Internet Gateway  
- **Amazon ECR** – Stores Docker images  
- **Amazon ECS (Fargate)** – Runs the containerized Node.js application  
- **IAM Roles** – Secure, keyless authentication for Jenkins and ECS  
- **Amazon CloudWatch Logs** – Application and container logging  

---

## Jenkins Pipeline Summary

The pipeline is defined using a declarative `Jenkinsfile` stored in GitHub.

### Pipeline Stages
- **Source** – Checkout code from GitHub  
- **Build** – Build Docker image  
- **Test** – Run container to verify application startup  
- **Push** – Authenticate and push image to Amazon ECR  
- **Deploy** – Force ECS service redeployment with the latest image  

Deployment failures are handled automatically using the ECS deployment circuit breaker.

---

## Security & Access

- Jenkins authenticates with AWS using **IAM roles**, not static credentials  
- ECS tasks use the default **ecsTaskExecutionRole**  
- Application and Jenkins access is controlled via **Security Groups**

---

## How to Run the Pipeline

1. Push code changes to the `main` branch on GitHub  
2. Jenkins pipeline triggers automatically via webhook  
3. Monitor pipeline execution in Jenkins console  
4. Verify deployment via ECS service events  
5. Access the application using the ECS task ENI IP on port `3000`

---

## Troubleshooting Highlights

- **AWS CLI not found on Jenkins Agent**  
  → Installed AWS CLI v2 on the agent instance  

- **ECS running old application version**  
  → Switched image tagging to `latest` and forced service redeploy  

- **GitHub webhook not triggering Jenkins**  
  → Assigned Elastic IP to Jenkins Master  

- **Jenkins Agent offline after restart**  
  → Reconnected agent using updated Jenkins Master IP  

---

