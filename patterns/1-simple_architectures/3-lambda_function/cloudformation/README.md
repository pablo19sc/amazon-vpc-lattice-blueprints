# Amazon VPC Lattice - Lambda Function Target (AWS CloudFormation)

![Lambda Function target](../../../../images/pattern1_architecture3.png)

## Prerequisites

- **AWS Account**: With appropriate IAM permissions
- **AWS CLI**: Installed and configured with credentials
- **Permissions required**:
  - CloudFormation
  - VPC Lattice
  - EC2: VPC, subnets, instances, security groups
  - Lambda: Create functions and permissions
  - IAM: Create roles and policies
- **Make**: Installed

## Deployment

```bash
# Clone the repository
git clone https://github.com/aws-samples/amazon-vpc-lattice-blueprints.git

# Navigate to the CloudFormation directory
cd patterns/1-simple_architectures/3-lambda_function/cloudformation

# Deploy everything (Networking + Consumer + Lambda Function)
make deploy

# Or deploy step-by-step:
make deploy-sn        # Deploy networking and service network first
make deploy-consumer  # Then deploy consumer VPC and instances
make deploy-provider  # Finally deploy Lambda function and VPC Lattice service
```

## Cleanup

```bash
# Delete everything
make undeploy
```

## Testing

After successful deployment, follow the testing instructions in the [Testing Connectivity](../README.md#testing-connectivity-2) section of the Lambda Function pattern documentation.

## Next Steps

After successfully deploying this pattern:

1. **Test connectivity**: Follow the testing guide to verify the service works correctly
2. **Explore other targets**: Try [EC2 Instance](../../1-ec2_instance/), [Lambda](../../3-lambda_function/), or [ECS](../../4-ecs/) patterns
3. **Multi-Account**: Move to [Multi-Account patterns](../../../2-multi_account/) for cross-account deployments
4. **Advanced architectures**: Explore [Advanced patterns](../../../3-advanced_architectures/) for more complex scenarios
