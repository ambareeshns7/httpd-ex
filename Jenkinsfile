pipeline {
    agent any
    
    environment {
        // Replace with your specific AWS details
        AWS_ACCOUNT_ID = '328911923780'
        AWS_REGION     = 'us-east-1'
        ECR_REPO_NAME  = 'jenkins'
        
        // Construct the full ECR Registry URL
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
                    // Builds the image and tags it with the Jenkins build number
                    dockerApp = docker.build("${IMAGE_NAME}:${env.BUILD_NUMBER}")
                }
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    // Uses the Amazon ECR plugin to handle login and push
                    docker.withRegistry("https://${REGISTRY_URL}", "ecr:${AWS_REGION}:aws-credentials") {
                        dockerApp.push("${env.BUILD_NUMBER}")
                        dockerApp.push("latest")
                    }
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
