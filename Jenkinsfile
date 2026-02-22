pipeline {
    agent any
    
    environment {
        AWS_ACCOUNT_ID = '328911923780'
        AWS_REGION     = 'us-east-1'
        ECR_REPO_NAME  = 'jenkins'
        REGISTRY_URL   = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        IMAGE_NAME     = "${REGISTRY_URL}/${ECR_REPO_NAME}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Docker Build') {
            steps {
                // We use 'sh' instead of 'docker.build' to avoid plugin errors
               // sh "docker build -t ${IMAGE_NAME}:${env.BUILD_NUMBER} ."
                sh "docker build --provenance=false -t ${IMAGE_NAME}:${env.BUILD_NUMBER} ."
                sh "docker tag ${IMAGE_NAME}:${env.BUILD_NUMBER} ${IMAGE_NAME}:latest"
            }
        }

        stage('ECR Login & Push') {
            steps {
                // Uses the EC2 IAM Role automatically
                sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${REGISTRY_URL}"
                sh "docker push ${IMAGE_NAME}:${env.BUILD_NUMBER}"
               // sh "docker push ${IMAGE_NAME}:latest"
            }
        }
        stage('Deploy to EKS') {
            steps {
                // Uses the EC2 IAM Role automatically
                sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${REGISTRY_URL}"
                sh "docker pull ${IMAGE_NAME}:${env.BUILD_NUMBER}"
                sh " kubectl apply -f deployment.yml"              
            }
        }
      //  stage('ECR Login & Pull') {
      //      steps {
                // Uses the EC2 IAM Role automatically
      //          sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${REGISTRY_URL}"
      //          sh "docker pull ${IMAGE_NAME}:${env.BUILD_NUMBER}"
      //          sh "docker run -d -p 80:80 ${IMAGE_NAME}:${env.BUILD_NUMBER}"
      //          sh "docker images"
      //          sh "docker ps"
      //      }
      //  }
    }

    post {
        always {
            // Clean up to save EC2 disk space
            sh "docker rmi ${IMAGE_NAME}:${env.BUILD_NUMBER} ${IMAGE_NAME}:latest || true"
        }
    }
}
