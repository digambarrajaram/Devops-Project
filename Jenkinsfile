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
                    script {
                        // Update kubeconfig for EKS
                        sh "aws eks update-kubeconfig --region $AWS_DEFAULT_REGION --name eks-cluster"

                        // Define file paths
                        def kubeDeploymentFile = "$KUBE_DEPLOYMENT"
                        def kubeServiceFile = "$KUBE_SERVICE"
                        def kubeIngressFile = "$KUBE_INGRESS"

                        // Read YAMLs
                        def deployYaml = readYaml(file: kubeDeploymentFile)
                        def serviceYaml = readYaml(file: kubeServiceFile)

                        // Extract namespace
                        def namespace = deployYaml.metadata.namespace ?: 'default'
                        sh "kubectl get namespace ${namespace} || kubectl create namespace ${namespace}"

                        // Update deployment image
                        deployYaml.spec.template.spec.containers[0].image = "$IMAGE_URI"

                        // Extract service name and type
                        def svcName = serviceYaml.metadata.name
                        def svcType = serviceYaml.spec.type
                        echo "Service name: ${svcName}"
                        echo "Namespace: ${namespace}"
                        echo "Service type from YAML: ${svcType}"

                        // Write updated deployment YAML
                        def modifiedDeploymentFile = "updated-deployment.yaml"
                        writeYaml(file: modifiedDeploymentFile, data: deployYaml)

                        // Write service YAML (unchanged)
                        def modifiedServiceFile = "updated-service.yaml"
                        writeYaml(file: modifiedServiceFile, data: serviceYaml)

                        // Apply deployment
                        sh "kubectl apply -f ${modifiedDeploymentFile} -n ${namespace}"

                        // Check existing service type and recreate if needed
                        def existingType = sh(
                            script: "kubectl get svc ${svcName} -n ${namespace} -o jsonpath='{.spec.type}' || echo none",
                            returnStdout: true
                        ).trim()

                        if (existingType != svcType) {
                            echo "Service type mismatch: existing=${existingType}, desired=${svcType}"
                            sh "kubectl delete svc ${svcName} -n ${namespace}"
                            sh "kubectl apply -f ${modifiedServiceFile} -n ${namespace}"
                        } else {
                            echo "Service type matches. No update needed."
                            sh "kubectl apply -f ${modifiedServiceFile} -n ${namespace}"
                        }

                        // Apply ingress
                        sh "kubectl apply -f ${kubeIngressFile} -n ${namespace}"

                        // Wait for rollout
                        def deployName = deployYaml.metadata.name
                        sh "kubectl rollout status deployment/${deployName} -n ${namespace}"

                        // Clean up
                        sh "rm ${modifiedDeploymentFile}"
                        sh "rm ${modifiedServiceFile}"
                    }
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
