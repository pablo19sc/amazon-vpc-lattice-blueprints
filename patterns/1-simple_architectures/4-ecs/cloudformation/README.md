# Amazon VPC Lattice - ECS Fargate Target (AWS CloudFormation)

![ECS Architecture](../../../../images/pattern1_architecture4.png)

## Prerequisites

- **AWS Account**: With appropriate IAM permissions
- **AWS CLI**: Installed and configured with credentials
- **Permissions required**:
  - CloudFormation
  - VPC Lattice
  - EC2: VPC, subnets, security groups
  - ECS: Cluster, task definition, service
  - ECR: Repository
  - IAM: Create roles and policies
  - Lambda: For custom resources
- **Make**: Installed
- **Docker**: For building and pushing container images to ECR

## Deployment

The Makefile automates the entire deployment process:

```bash
# Clone the repository
git clone https://github.com/aws-samples/amazon-vpc-lattice-blueprints.git

# Navigate to the CloudFormation directory
cd patterns/1-simple_architectures/4-ecs/cloudformation

# Deploy everything (this will take several minutes)
make deploy

# Or specify a different region (default is us-east-1)
make deploy REGION=eu-west-1
```

The `make deploy` command performs the following steps automatically:

1. **Deploy ECR Repository**: Creates the ECR repository
2. **Build & Push Image**: Builds the Docker image and pushes it to ECR
3. **Deploy Service Network**: Creates VPC Lattice service network
4. **Deploy Provider VPC**: Creates the provider VPC, VPC Lattice service, target group, and ECS infrastructure
5. **Deploy Consumer VPC**: Creates the consumer VPC and EC2 instances

### Manual Step-by-Step Deployment

If you prefer to deploy step-by-step:

```bash
# Step 1: Deploy ECR repository
make deploy-repository

# Step 2: Build and push Docker image
make build-push

# Step 3: Deploy VPC Lattice service network
make deploy-sn

# Step 4: Deploy provider VPC, VPC Lattice service, and ECS infrastructure
make deploy-provider

# Step 5: Deploy consumer VPC
make deploy-consumer
```

> **Note**: The Makefile configuration automatically detects your system architecture and configures the ECS task definition accordingly. The Docker image must be built for the same architecture. EC2 instances and ECS Fargate will be deployed in all the Availability Zones configured for the VPC. Keep this in mind when testing this environment from a cost perspective - for production environments, we recommend the use of at least 2 AZs for high-availability.

## Cleanup

```bash
# Delete all CloudFormation stacks
make undeploy

# Or delete everything including ECR repository and images
make clean
```

## Testing

After deployment, follow the testing steps in the [Pattern 1 - ECS Testing Connectivity section](../../README.md#4-ecs-fargate) to verify connectivity between consumer instances and ECS tasks through VPC Lattice.

## Next Steps

After successfully deploying this pattern:

1. **Test connectivity**: Follow the testing guide to verify both services work correctly.
2. **Explore other targets**: Try [Auto Scaling Group](../../2-auto_scaling_group/), [Lambda](../../3-lambda_function/), or [ECS](../../4-ecs/) patterns.
3. **Multi-Account**: Move to [Multi-Account patterns](../../../2-multi_account/) for cross-account deployments.
4. **Advanced architectures**: Explore [Advanced patterns](../../../3-advanced_architectures/) for more complex scenarios.
