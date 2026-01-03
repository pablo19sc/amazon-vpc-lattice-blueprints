.PHONY: deploy deploy-repository build-push deploy-provider deploy-sn deploy-consumer undeploy clean

# Default region
REGION ?= eu-west-1

# Detect platform architecture
PLATFORM := $(shell uname -m)
ifeq ($(PLATFORM),arm64)
	DOCKER_PLATFORM := linux/arm64
	ECS_CPU_ARCH := ARM64
else ifeq ($(PLATFORM),aarch64)
	DOCKER_PLATFORM := linux/arm64
	ECS_CPU_ARCH := ARM64
else
	DOCKER_PLATFORM := linux/amd64
	ECS_CPU_ARCH := X86_64
endif

deploy: deploy-repository build-push deploy-sn deploy-provider deploy-consumer
	@echo "=========================================="
	@echo "Deployment completed successfully!"
	@echo "=========================================="

deploy-repository:
	@echo "=========================================="
	@echo "Step 1: Deploying ECR repository..."
	@echo "=========================================="
	aws cloudformation deploy --stack-name vpclattice-ecs-target-repository --template-file repository.yaml --no-fail-on-empty-changeset --region $(REGION)

build-push: REPOSITORY_URL = $(shell aws cloudformation describe-stacks --stack-name "vpclattice-ecs-target-repository" --query 'Stacks[0].Outputs[?OutputKey == `ECRRepositoryUri`].OutputValue' --output text --region $(REGION))
build-push: AWS_ACCOUNT_ID = $(shell echo $(REPOSITORY_URL) | cut -d'.' -f1)
build-push:
	@echo ""
	@echo "=========================================="
	@echo "Step 2: Building and pushing Docker image..."
	@echo "=========================================="
	@echo "ECR Repository URL: $(REPOSITORY_URL)"
	@echo "Detected platform: $(PLATFORM)"
	@echo "Building for: $(DOCKER_PLATFORM)"
	@echo ""
	@echo "Logging in to ECR..."
	@aws ecr get-login-password --region $(REGION) | docker login --username AWS --password-stdin $(AWS_ACCOUNT_ID).dkr.ecr.$(REGION).amazonaws.com
	@echo ""
	@echo "Building Docker image..."
	@cd ../application && docker build --platform $(DOCKER_PLATFORM) -t $(REPOSITORY_URL):latest .
	@echo ""
	@echo "Pushing image to ECR..."
	@docker push $(REPOSITORY_URL):latest
	@echo ""
	@echo "Successfully pushed image to $(REPOSITORY_URL):latest"

deploy-sn:
	@echo ""
	@echo "=========================================="
	@echo "Step 3: Deploying VPC Lattice service network..."
	@echo "=========================================="
	aws cloudformation deploy --stack-name vpclattice-ecs-target-networking --template-file networking.yaml --no-fail-on-empty-changeset --region $(REGION)

deploy-provider: REPOSITORY_URL = $(shell aws cloudformation describe-stacks --stack-name "vpclattice-ecs-target-repository" --query 'Stacks[0].Outputs[?OutputKey == `ECRRepositoryUri`].OutputValue' --output text --region $(REGION))
deploy-provider: SERVICENETWORK = $(shell aws cloudformation describe-stacks --stack-name "vpclattice-ecs-target-networking" --query 'Stacks[0].Outputs[?OutputKey == `VpcLatticeServiceNetworkId`].OutputValue' --output text --region $(REGION))
deploy-provider:
	@echo ""
	@echo "=========================================="
	@echo "Step 4: Deploying provider VPC, VPC Lattice service, and ECS infrastructure..."
	@echo "=========================================="
	@echo "Detected CPU architecture: $(ECS_CPU_ARCH)"
	aws cloudformation deploy --stack-name vpclattice-ecs-target-provider --template-file provider.yaml --parameter-overrides ServiceNetworkId="$(SERVICENETWORK)" ECRRepositoryUri="$(REPOSITORY_URL)" ECSCpuArchitecture="$(ECS_CPU_ARCH)" --capabilities CAPABILITY_NAMED_IAM --no-fail-on-empty-changeset --region $(REGION)

deploy-consumer: SERVICENETWORK = $(shell aws cloudformation describe-stacks --stack-name "vpclattice-ecs-target-networking" --query 'Stacks[0].Outputs[?OutputKey == `VpcLatticeServiceNetworkId`].OutputValue' --output text --region $(REGION))
deploy-consumer:
	@echo ""
	@echo "=========================================="
	@echo "Step 5: Deploying consumer VPC and EC2 instances..."
	@echo "=========================================="
	aws cloudformation deploy --stack-name vpclattice-ecs-target-consumer --template-file consumer.yaml --parameter-overrides ServiceNetworkId="$(SERVICENETWORK)" --capabilities CAPABILITY_IAM --no-fail-on-empty-changeset --region $(REGION)

undeploy:
	@echo "=========================================="
	@echo "Cleaning up resources..."
	@echo "=========================================="
	aws cloudformation delete-stack --stack-name vpclattice-ecs-target-consumer --region $(REGION)
	aws cloudformation delete-stack --stack-name vpclattice-ecs-target-provider --region $(REGION)
	aws cloudformation wait stack-delete-complete --stack-name vpclattice-ecs-target-consumer --region $(REGION)
	aws cloudformation wait stack-delete-complete --stack-name vpclattice-ecs-target-provider --region $(REGION)
	aws cloudformation delete-stack --stack-name vpclattice-ecs-target-networking --region $(REGION)
	aws cloudformation wait stack-delete-complete --stack-name vpclattice-ecs-target-networking --region $(REGION)
	aws cloudformation delete-stack --stack-name vpclattice-ecs-target-repository --region $(REGION)
	aws cloudformation wait stack-delete-complete --stack-name vpclattice-ecs-target-repository --region $(REGION)
	@echo ""
	@echo "=========================================="
	@echo "Cleanup completed successfully!"
	@echo "=========================================="
