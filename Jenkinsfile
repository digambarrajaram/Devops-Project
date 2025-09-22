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
                    IMAGE_TAG = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    IMAGE_URI = "${ECR_REGISTRY}/${ECR_REPO}:${IMAGE_TAG}"
                    env.IMAGE_TAG = IMAGE_TAG
                    env.IMAGE_URI = IMAGE_URI
                    echo "Image URI set to: $IMAGE_URI"
                }
            }
        }

        stage('Build & Push Docker Image') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'awscred']]) {
                    sh """
                        aws ecr get-login-password --region $AWS_DEFAULT_REGION | \
                        docker login --username AWS --password-stdin $ECR_REGISTRY

                        docker build -t $IMAGE_URI $APP_DIR
                        docker push $IMAGE_URI
                    """
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'awscred']]) {
                    sh '''
                        # Update kubeconfig
                        aws eks update-kubeconfig --region $AWS_DEFAULT_REGION --name eks-cluster

                        # Extract namespace from deployment YAML
                        NAMESPACE=$(yq eval '.metadata.namespace' $KUBE_DEPLOYMENT)
                        [ -z "$NAMESPACE" ] && NAMESPACE="default"
                        kubectl get namespace $NAMESPACE || kubectl create namespace $NAMESPACE

                        # Update deployment image dynamically
                        sed -i "s|image:.*|image: $IMAGE_URI|" $KUBE_DEPLOYMENT
                        kubectl apply -f $KUBE_DEPLOYMENT -n $NAMESPACE

                        # Extract service name and type from YAML dynamically
                        SVC_NAME=$(yq eval '.metadata.name' $KUBE_SERVICE)
                        SVC_TYPE=$(yq eval '.spec.type' $KUBE_SERVICE)
                        kubectl apply -f $KUBE_SERVICE -n $NAMESPACE
                        kubectl patch svc $SVC_NAME -n $NAMESPACE -p "{\"spec\":{\"type\":\"$SVC_TYPE\"}}"
                        # Apply ingress dynamically
                        kubectl apply -f $KUBE_INGRESS -n $NAMESPACE

                        # Wait for deployment rollout
                        DEPLOY_NAME=$(yq eval '.metadata.name' $KUBE_DEPLOYMENT)
                        kubectl rollout status deployment/$DEPLOY_NAME -n $NAMESPACE
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
