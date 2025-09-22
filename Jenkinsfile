pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = "ap-south-1"
        ECR_REPO = "application_docker_repo"
        IMAGE_NAME = 'python-app'
        IMAGE_TAG = "latest"
        APP_DIR = "devops-project/python-app"
        ECR_REGISTRY = '605134452604.dkr.ecr.ap-south-1.amazonaws.com'
        IMAGE_URI = "${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}"
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
                    docker.build("${IMAGE_URI}", "${APP_DIR}")
                }
            }
        }

        stage('Login to ECR') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'awscred']]) {
                    sh '''
                        aws ecr get-login-password --region $AWS_DEFAULT_REGION | \
                        docker login --username AWS --password-stdin $ECR_REGISTRY
                    '''
                }
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    docker.image("${IMAGE_URI}").push()
                }
            }
        }
    }

    post {
        always {
            echo 'Pipeline completed.'
        }
    }
}
