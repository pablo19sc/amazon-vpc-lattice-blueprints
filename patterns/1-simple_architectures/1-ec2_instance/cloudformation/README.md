# Amazon VPC Lattice - EC2 Instance Target (AWS CloudFormation)

![EC2 Instance Architecture](../../../../images/pattern1_architecture1.png)

## Prerequisites

- **AWS Account**: With appropriate IAM permissions
- **AWS CLI**: Installed and configured with credentials
- **Permissions required**:
  - CloudFormation
  - VPC Lattice
  - EC2: VPC, subnets, instances, security groups
  - IAM: Create roles and policies
- **Make**: Installed
- **(Optional) Custom Domain Name**: If you want to configure Service2 with a custom domain name:
  - A registered domain name
  - ACM certificate ARN for the domain
  - Route 53 hosted zone name

## Deployment

```bash
# Clone the repository
git clone https://github.com/aws-samples/amazon-vpc-lattice-blueprints.git

# Navigate to the CloudFormation directory
cd patterns/1-simple_architectures/1-ec2_instance/cloudformation

# Set custom domain configuration
export CUSTOM_DOMAIN_NAME="service2.example.com"
export CERTIFICATE_ARN="arn:aws:acm:eu-west-1:123456789012:certificate/xxxxx"
export HOSTED_ZONE_NAME="example.com"

# Deploy everything
make deploy

# Or deploy step-by-step:
make deploy-sn        # service network
make deploy-consumer  # consumer VPC and EC2 instances
make deploy-provider  # provider VPC and VPC Lattice services
```

> **Note**: EC2 instances will be deployed in all the Availability Zones configured for each VPC. Keep this in mind when testing this environment from a cost perspective - for production environments, we recommend the use of at least 2 AZs for high-availability.

## Cleanup

```bash
# Delete everything
make undeploy
```

## Testing

After successful deployment, follow the testing instructions in the [Testing Connectivity](../README.md#testing-connectivity) section of the EC2 Instance pattern documentation.

## Next Steps

After successfully deploying this pattern:

1. **Test connectivity**: Follow the testing guide to verify both services work correctly.
2. **Explore other targets**: Try [Auto Scaling Group](../../2-auto_scaling_group/), [Lambda](../../3-lambda_function/), or [ECS](../../4-ecs/) patterns.
3. **Multi-Account**: Move to [Multi-Account patterns](../../../2-multi_account/) for cross-account deployments.
4. **Advanced architectures**: Explore [Advanced patterns](../../../3-advanced_architectures/) for more complex scenarios.
