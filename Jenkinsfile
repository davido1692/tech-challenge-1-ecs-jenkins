pipeline {
  agent any

  environment {
    AWS_REGION = "us-east-1"
    AWS_ACCOUNT_ID = "751545121618"

    BACKEND_ECR_REPO = "tc1-backend"
    FRONTEND_ECR_REPO = "tc1-frontend"
  }

  stages {

    stage("Checkout") {
      steps {
        checkout scm
      }
    }

    stage("Build Docker Images") {
      steps {
        sh '''
          docker build -t backend:latest backend
          docker build -t frontend:latest frontend
        '''
      }
    }

    stage("Login to ECR") {
      steps {
        sh '''
          aws ecr get-login-password --region $AWS_REGION \
          | docker login --username AWS --password-stdin \
          $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
        '''
      }
    }

    stage("Tag & Push Images") {
      steps {
        sh '''
          docker tag backend:latest \
            $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$BACKEND_ECR_REPO:latest

          docker tag frontend:latest \
            $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$FRONTEND_ECR_REPO:latest

          docker push \
            $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$BACKEND_ECR_REPO:latest

          docker push \
            $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$FRONTEND_ECR_REPO:latest
        '''
      }
    }
  }
}
