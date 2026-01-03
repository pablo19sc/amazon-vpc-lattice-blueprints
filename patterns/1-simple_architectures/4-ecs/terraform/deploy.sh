#!/bin/bash

set -e

echo "=========================================="
echo "ECS Fargate Deployment Script"
echo "=========================================="
echo ""

# Step 1: Deploy ECR repository only
echo "Step 1: Deploying ECR repository..."
terraform init
terraform apply -target=aws_ecr_repository.ecr_repository -auto-approve

# Step 2: Get ECR repository URL
echo ""
echo "Step 2: Getting ECR repository URL..."
REPOSITORY_URL=$(terraform output -raw repository_url)
echo "ECR Repository URL: ${REPOSITORY_URL}"

# Step 3: Build and push Docker image
echo ""
echo "Step 3: Building and pushing Docker image..."
export REPOSITORY_URL

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Extract region from repository URL
REGION=$(echo $REPOSITORY_URL | cut -d'.' -f4)

# Extract AWS account ID from repository URL
AWS_ACCOUNT_ID=$(echo $REPOSITORY_URL | cut -d'.' -f1)

# Detect platform architecture
PLATFORM=$(uname -m)
echo "Detected platform: ${PLATFORM}"

# Determine Docker build platform
if [ "$PLATFORM" = "arm64" ] || [ "$PLATFORM" = "aarch64" ]; then
    echo "Building for linux/arm64 (native ARM platform)"
    DOCKER_PLATFORM="--platform linux/arm64"
else
    echo "Building for linux/amd64 (native x86_64 platform)"
    DOCKER_PLATFORM="--platform linux/amd64"
fi

echo "Building and pushing Docker image to: ${REPOSITORY_URL}:latest"

# Login to ECR
aws ecr get-login-password --region ${REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com

# Build the Docker image (from application directory)
cd "${SCRIPT_DIR}/../application"
docker build ${DOCKER_PLATFORM} -t ${REPOSITORY_URL}:latest .

# Push the image to ECR
docker push ${REPOSITORY_URL}:latest

echo ""
echo "Successfully pushed image to ${REPOSITORY_URL}:latest"

# Step 4: Deploy remaining infrastructure
echo ""
echo "Step 4: Deploying remaining infrastructure..."
cd "${SCRIPT_DIR}"
terraform apply -auto-approve

echo ""
echo "=========================================="
echo "Deployment completed successfully!"
echo "=========================================="
