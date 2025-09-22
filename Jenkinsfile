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
                        # Ensure yq is available in the shell environment.
                        # If not, you may need to install it with:
                        # pip install yq
                        # or wget and move the binary to your PATH.
                        # For example:
                        # wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
                        # chmod +x /usr/local/bin/yq

                        # Update kubeconfig
                        aws eks update-kubeconfig --region $AWS_DEFAULT_REGION --name eks-cluster

                        # Extract namespace from deployment YAML
                        NAMESPACE=$(yq e '.metadata.namespace' $KUBE_DEPLOYMENT)
                        [ -z "$NAMESPACE" ] && NAMESPACE="default"
                        kubectl get namespace $NAMESPACE || kubectl create namespace $NAMESPACE

                        # Update deployment image dynamically
                        yq e -i ".spec.template.spec.containers[0].image = \"$IMAGE_URI\"" $KUBE_DEPLOYMENT
                        kubectl apply -f $KUBE_DEPLOYMENT -n $NAMESPACE

                        # Extract service name and type from YAML dynamically
                        SVC_NAME=$(yq e '.metadata.name' $KUBE_SERVICE)
                        SVC_TYPE=$(yq e '.spec.type' $KUBE_SERVICE)
                        echo "Service name: $SVC_NAME"
                        echo "Namespace: $NAMESPACE"
                        echo "Service type from YAML: $SVC_TYPE"

                        # Check existing service type and recreate if needed
                        EXISTING_TYPE=$(kubectl get svc "$SVC_NAME" -n "$NAMESPACE" -o jsonpath='{.spec.type}' 2>/dev/null || echo "none")

                        # The `kubectl apply` command will handle the update correctly,
                        # including the service type change, without needing to delete and recreate.
                        # We can remove the if/else block to simplify the logic.
                        kubectl apply -f "$KUBE_SERVICE" -n "$NAMESPACE"

                        # Apply ingress dynamically
                        kubectl apply -f $KUBE_INGRESS -n $NAMESPACE

                        # Wait for deployment rollout
                        DEPLOY_NAME=$(yq e '.metadata.name' $KUBE_DEPLOYMENT)
                        kubectl rollout status deployment/$DEPLOY_NAME -n $NAMESPACE
                    '''
                }
            }
        }

    post {
        always {
            echo "Pipeline completed."
        }
    }
}
