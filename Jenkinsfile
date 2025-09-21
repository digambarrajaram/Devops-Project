pipeline {
    agent any

    environment {
        registryCredential = 'ecr:ap-south-1:awscred'
        AWS_DEFAULT_REGION = "ap-south-1"
        ECR_REPO = "605134452604.dkr.ecr.ap-south-1.amazonaws.com/application_docker_repo"
        IMAGE_TAG = "latest"
        APP_DIR = "devops-project/python-app"
    }

    stages {
        stage('Checkout') {
            steps {
                 git branch: 'main', url: 'https://github.com/digambarrajaram/Devops-Project.git'
                  }

        }

        stage('Build Docker Image') {
                    steps {
                        script {
                            dir('Docker-files/app/multistage') {
                                withAWS(credentials: 'awscreds', region: "${AWS_REGION}") {
                                    sh """
                                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${APP_REPO}
                                        docker build -t ${APP_REPO}:${IMAGE_TAG} .
                                    """
                                }
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
