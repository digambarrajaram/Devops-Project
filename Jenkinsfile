pipeline {
    agent any
    environment {
        AWS_DEFAULT_REGION = "ap-south-1"
        ECR_REPO = "application_docker_repo"
        IMAGE_NAME = 'python-app'
        IMAGE_TAG = "${env.GIT_COMMIT}"
        APP_DIR = "python-app/"
        ECR_REGISTRY = '605134452604.dkr.ecr.ap-south-1.amazonaws.com'
        IMAGE_URI = "${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}"
        KUBE_DEPLOYMENT = "python-app/k8s-deployment.yaml"
        KUBE_SERVICE = "python-app/k8s-service.yaml"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/digambarrajaram/Devops-Project.git'
            }
        }

stage('Build & Push Docker Image') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'awscred']]) {
                    sh '''
                        aws ecr get-login-password --region $AWS_DEFAULT_REGION | \
                        docker login --username AWS --password-stdin $ECR_REGISTRY

                        docker build -t $IMAGE_URI python-app/
                        docker push $IMAGE_URI
                    '''
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'awscred']]) {
                    sh '''
                        aws eks update-kubeconfig --region $AWS_DEFAULT_REGION --name eks-cluster

                        # Replace image tag in deployment YAML
                        sed -i "s|image:.*|image: $IMAGE_URI|" $KUBE_DEPLOYMENT

                        kubectl apply -f $KUBE_DEPLOYMENT
                        kubectl apply -f $KUBE_SERVICE
                    '''
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
