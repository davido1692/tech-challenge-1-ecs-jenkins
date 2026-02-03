pipeline {
  agent any

  environment {
    AWS_REGION      = 'us-east-1'
    AWS_ACCOUNT_ID  = '751545121618'

    ECR_BACKEND_REPO   = 'tc1-backend'
    ECR_FRONTEND_REPO  = 'tc1-frontend'

    ECS_CLUSTER          = 'tc1-cluster'
    ECS_BACKEND_SERVICE  = 'tc1-svc-backend'
    ECS_FRONTEND_SERVICE = 'tc1-svc-frontend'

    ECR_REGISTRY = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    IMAGE_TAG    = "${env.GIT_COMMIT ? env.GIT_COMMIT.take(7) : env.BUILD_NUMBER}"

    // Prevent AWS CLI pager errors in containers
    AWS_PAGER = ''
  }

  stages {

    stage('Checkout') {
      steps {
        deleteDir()
        checkout scm
      }
    }

    stage('Show Tools') {
      steps {
        sh '''
          set -e
          docker --version
          aws --version
        '''
      }
    }

    stage('Login ECR') {
      steps {
        sh '''
          set -e
          aws sts get-caller-identity

          aws ecr get-login-password --region "$AWS_REGION" \
            | docker login --username AWS --password-stdin "$ECR_REGISTRY"
        '''
      }
    }

    stage('Build Images') {
      steps {
        sh '''
          set -e
          echo "Building backend..."
          docker build -t tc1-backend:$IMAGE_TAG ./backend

          echo "Building frontend..."
          docker build -t tc1-frontend:$IMAGE_TAG ./frontend
        '''
      }
    }

    stage('Tag & Push Images') {
      steps {
        sh '''
          set -e
          BACKEND_ECR="$ECR_REGISTRY/$ECR_BACKEND_REPO"
          FRONTEND_ECR="$ECR_REGISTRY/$ECR_FRONTEND_REPO"

          echo "Tagging..."
          docker tag tc1-backend:$IMAGE_TAG  $BACKEND_ECR:$IMAGE_TAG
          docker tag tc1-frontend:$IMAGE_TAG $FRONTEND_ECR:$IMAGE_TAG

          echo "Pushing..."
          docker push $BACKEND_ECR:$IMAGE_TAG
          docker push $FRONTEND_ECR:$IMAGE_TAG
        '''
      }
    }

    stage('Deploy ECS') {
      steps {
        sh '''
          set -e
          echo "Forcing new deployment so ECS pulls new images..."

          aws ecs update-service --region "$AWS_REGION" --cluster "$ECS_CLUSTER" --service "$ECS_BACKEND_SERVICE" --force-new-deployment
          aws ecs update-service --region "$AWS_REGION" --cluster "$ECS_CLUSTER" --service "$ECS_FRONTEND_SERVICE" --force-new-deployment

          echo "Done. Service status:"
          aws ecs describe-services --region "$AWS_REGION" --cluster "$ECS_CLUSTER" \
            --services "$ECS_BACKEND_SERVICE" "$ECS_FRONTEND_SERVICE" \
            --query "services[].{name:serviceName,desired:desiredCount,running:runningCount,pending:pendingCount,status:status}" \
            --output table
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
