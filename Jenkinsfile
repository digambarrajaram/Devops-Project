pipeline {
  agent any

  environment {
    AWS_ACCESS_KEY_ID     = credentials('awscred')      // Jenkins credential ID
    AWS_SECRET_ACCESS_KEY = credentials('awscred')  // Jenkins credential ID
    AWS_DEFAULT_REGION    = 'ap-south-1'
    TF_BUCKET             = 'backend-terraform-state-bucket-for-vpc-and-eks'           // Replace with your S3 bucket
    TF_KEY                = 'eks/vpc/terraform.tfstate'
    TF_DYNAMODB_TABLE     = 'terraform-lock'
  }

  stages {
    stage('Checkout') {
      steps {
        git url: 'https://github.com/digambarrajaram/Devops-Project.git', branch: 'main'
      }
    }

    stage('Terraform Init') {
      steps {
        sh '''
          terraform init \
            -backend-config="bucket=${TF_BUCKET}" \
            -backend-config="key=${TF_KEY}" \
            -backend-config="region=${AWS_DEFAULT_REGION}" \
            -backend-config="dynamodb_table=${TF_DYNAMODB_TABLE}"
        '''
      }
    }

    stage('Terraform Validate') {
      steps {
        sh 'terraform validate'
      }
    }

    stage('Terraform Plan') {
      steps {
        sh 'terraform plan -out=tfplan'
      }
    }

    stage('Terraform Apply') {
      steps {
        input message: 'Approve Terraform Apply?'
        sh 'terraform apply tfplan'
      }
    }

    stage('Terraform Destroy') {
      when {
        expression { return params.DESTROY_INFRA == true }
      }
      steps {
        input message: 'Confirm Terraform Destroy?'
        sh 'terraform destroy -auto-approve'
      }
    }
  }

  parameters {
    booleanParam(name: 'DESTROY_INFRA', defaultValue: false, description: 'Check to destroy infrastructure')
  }

  post {
    success {
      echo 'Terraform pipeline completed successfully.'
    }
    failure {
      echo 'Terraform pipeline failed.'
    }
  }
}

