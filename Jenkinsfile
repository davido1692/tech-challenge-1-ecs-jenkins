pipeline {
  agent any
  options { timestamps() }

  environment {
    AWS_REGION     = "us-east-1"
    AWS_ACCOUNT_ID = "751545121618"

    // ECR (already created by Terraform)
    BACKEND_ECR_REPO  = "tc1-backend"
    FRONTEND_ECR_REPO = "tc1-frontend"

    // ECS (confirmed from your output)
    ECS_CLUSTER          = "tc1-cluster"
    // ECS_BACKEND_SERVICE  = "tc1-backend-svc"
    // ECS_FRONTEND_SERVICE = "tc1-frontend-svc"

    ECS_BACKEND_SERVICE  = "tc1-svc-backend"
    ECS_FRONTEND_SERVICE = "tc1-svc-frontend"


    // ALB (confirmed from your output)
    ALB_NAME = "k8s-default-flaskhel-61550f12c3"
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
          set -e
          docker build -t backend:latest backend
          docker build -t frontend:latest frontend
        '''
      }
    }

    stage("Login to ECR") {
      steps {
        sh '''
          set -e
          aws ecr get-login-password --region "$AWS_REGION" \
          | docker login --username AWS --password-stdin \
          "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
        '''
      }
    }

    stage("Tag & Push Images") {
      steps {
        sh '''
          set -e
          BACKEND_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$BACKEND_ECR_REPO"
          FRONTEND_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$FRONTEND_ECR_REPO"

          docker tag backend:latest  "$BACKEND_URI:latest"
          docker tag frontend:latest "$FRONTEND_URI:latest"

          docker push "$BACKEND_URI:latest"
          docker push "$FRONTEND_URI:latest"
        '''
      }
    }

    stage("Deploy to ECS (force new deployment)") {
      steps {
        sh '''
          set -e
          echo "Forcing new deployments so ECS pulls latest images..."

          aws ecs update-service \
            --region "$AWS_REGION" \
            --cluster "$ECS_CLUSTER" \
            --service "$ECS_BACKEND_SERVICE" \
            --force-new-deployment

          aws ecs update-service \
            --region "$AWS_REGION" \
            --cluster "$ECS_CLUSTER" \
            --service "$ECS_FRONTEND_SERVICE" \
            --force-new-deployment

          echo "Waiting for services to become stable..."
          aws ecs wait services-stable \
            --region "$AWS_REGION" \
            --cluster "$ECS_CLUSTER" \
            --services "$ECS_BACKEND_SERVICE" "$ECS_FRONTEND_SERVICE"

          echo "Service status:"
          aws ecs describe-services \
            --region "$AWS_REGION" \
            --cluster "$ECS_CLUSTER" \
            --services "$ECS_BACKEND_SERVICE" "$ECS_FRONTEND_SERVICE" \
            --query "services[].{name:serviceName,desired:desiredCount,running:runningCount,pending:pendingCount,status:status}" \
            --output table
        '''
      }
    }

    stage("Print URL") {
      steps {
        sh '''
          set -e
          DNS=$(aws elbv2 describe-load-balancers \
            --names "$ALB_NAME" \
            --region "$AWS_REGION" \
            --query "LoadBalancers[0].DNSName" \
            --output text)

          echo "======================================"
          echo "Deployment complete."
          echo "URL: http://$DNS"
          echo "======================================"
        '''
      }
    }
  }

  post {
    always {
      sh '''
        echo "Pruning unused images (best effort)..."
        docker image prune -f || true
      '''
    }
  }
}
