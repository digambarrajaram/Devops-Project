pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = "ap-south-1"
        ECR_REPO = "application_docker_repo"
        IMAGE_NAME = "python-app"
        APP_DIR = "python-app/"
        ECR_REGISTRY = "605134452604.dkr.ecr.ap-south-1.amazonaws.com"
        KUBE_DEPLOYMENT = "python-app/k8s-deployment.yaml"
        KUBE_SERVICE = "python-app/k8s-service.yaml"
        KUBE_INGRESS = "python-app/k8s-ingress.yaml"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/digambarrajaram/Devops-Project.git'
            }
        }

        stage('Set Image Tag') {
            steps {
                script {
                    // use Git commit short SHA as tag
                    IMAGE_TAG = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    IMAGE_URI = "${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}"
                    env.IMAGE_TAG = IMAGE_TAG
                    env.IMAGE_URI = IMAGE_URI
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'awscred']]) {
                    sh '''
                        aws ecr get-login-password --region $AWS_DEFAULT_REGION | \
                        docker login --username AWS --password-stdin $ECR_REGISTRY

                        docker build -t $IMAGE_URI $APP_DIR
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

                        # Ensure namespace exists
                        kubectl get namespace devops-app || kubectl create namespace devops-app

                        # Update deployment with latest image
                        sed -i "s|image:.*|image: $IMAGE_URI|" $KUBE_DEPLOYMENT

                        kubectl apply -f $KUBE_DEPLOYMENT -n devops-app
                        kubectl apply -f $KUBE_SERVICE -n devops-app
                        kubectl apply -f $KUBE_INGRESS -n devops-app

                        kubectl rollout status deployment/python-app-deployment -n devops-app
                    '''
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline completed."
        }
    }
}
