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
                script {
                    // Builds the image locally
                    dockerApp = docker.build("${IMAGE_NAME}:${env.BUILD_NUMBER}")
                }
            }
        }

        stage('ECR Login & Push') {
            steps {
                script {
                    // Use IAM Role to login without needing a credential ID
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${REGISTRY_URL}"
                    
                    // Push both the build number and latest tags
                    sh "docker tag ${IMAGE_NAME}:${env.BUILD_NUMBER} ${IMAGE_NAME}:latest"
                    sh "docker push ${IMAGE_NAME}:${env.BUILD_NUMBER}"
                    sh "docker push ${IMAGE_NAME}:latest"
                }
            }
        }
    }

    post {
        always {
            // Clean up local images to save disk space
            sh "docker rmi ${IMAGE_NAME}:${env.BUILD_NUMBER} ${IMAGE_NAME}:latest || true"
        }
    }
}
