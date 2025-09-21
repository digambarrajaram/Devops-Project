pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = "ap-south-1"
        ECR_REPO = "605134452604.dkr.ecr.ap-south-1.amazonaws.com/application_docker_repo"
        IMAGE_TAG = "latest"
        APP_DIR = "devops-project/python-app"
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/yourusername/devops-project.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    dir(APP_DIR) {
                        sh """
                            aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $ECR_REPO
                            docker build -t $ECR_REPO:$IMAGE_TAG .
                        """
                    }
                }
            }
        }

        stage('Push to ECR') {
            steps {
                dir(APP_DIR) {
                    sh "docker push $ECR_REPO:$IMAGE_TAG"
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                script {
                    dir(APP_DIR) {
                        sh """
                            kubectl set image deployment/flask-app flask-container=$ECR_REPO:$IMAGE_TAG --record || \
                            kubectl apply -f k8s-deployment.yaml
                            kubectl apply -f k8s-service.yaml
                        """
                    }
                }
            }
        }
    }
}
