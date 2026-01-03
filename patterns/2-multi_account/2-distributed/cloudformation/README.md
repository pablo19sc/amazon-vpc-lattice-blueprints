# Amazon VPC Lattice - Multi-Account: Distributed Service Networks (AWS CloudFormation)

![Distributed Service Network](../../../../images/distributed.png)

## Prerequisites

- **Two AWS Accounts**: Service provider account and consumer account.
- **AWS Organizations**: All accounts must be part of the same AWS Organization.
- **AWS CLI**: Installed and configured with credentials for each account.
- **Permissions required** (per account):
  - CloudFormation: Create and manage stacks.
  - VPC Lattice: Service networks, services, target groups.
  - AWS RAM (Resource Access Manager): Create and manage resource shares.
  - AWS Organizations: Read access to describe organization.
  - EC2: VPC, subnets, instances, security groups (consumer account).
  - Lambda: Create functions and execution roles (service account).
  - IAM: Create roles and policies.

## Deployment

> **Important**: Resources must be deployed in a specific order due to cross-account dependencies. Each step must be completed in the specified AWS Account.

### Step 1: Service Provider Account - Deploy VPC Lattice Service

**AWS Account**: Service Provider Account

Deploy the Lambda function and VPC Lattice service:

```bash
# Configure AWS credentials for service provider account
export AWS_PROFILE=service-provider

# Deploy the service
aws cloudformation deploy \
  --template-file service-account.yaml \
  --stack-name vpclattice-distributed-service \
  --capabilities CAPABILITY_NAMED_IAM \
  --region eu-west-1
```

### Step 2: Consumer Account - Deploy Service Network, VPCs, and Associations

**AWS Account**: Consumer Account

Deploy the service network, consumer VPCs, EC2 instances, and associations:

```bash
# Configure AWS credentials for consumer account
export AWS_PROFILE=consumer-account

# Deploy consumer resources
aws cloudformation deploy \
  --template-file consumer-account.yaml \
  --stack-name vpclattice-distributed-consumer \
  --region eu-west-1
```

## Cleanup

> **Important**: Delete resources in reverse order to avoid dependency issues.

### Step 1: Consumer Account

```bash
export AWS_PROFILE=consumer-account
aws cloudformation delete-stack --stack-name vpclattice-distributed-consumer --region eu-west-1
aws cloudformation wait stack-delete-complete --stack-name vpclattice-distributed-consumer --region eu-west-1
```

### Step 2: Service Provider Account

```bash
export AWS_PROFILE=service-provider
aws cloudformation delete-stack --stack-name vpclattice-distributed-service --region eu-west-1
aws cloudformation wait stack-delete-complete --stack-name vpclattice-distributed-service --region eu-west-1
```

## Next Steps

After successfully deploying this pattern:

1. **Test connectivity**: Follow the testing guide to verify the service works correctly.
2. **Explore centralized pattern**: Try the [Centralized Service Network](../../1-centralized_service_network/) pattern for central network governance.
3. **Advanced architectures**: Explore [Advanced patterns](../../../3-advanced_architectures/) for more complex scenarios.
4. **Custom domains**: Implement custom domain names with Route 53 Private Hosted Zones (PHZs) and certificates. Implement automated DNS configuration using the [VPC Lattice DNS Guidance](https://aws.amazon.com/solutions/guidance/amazon-vpc-lattice-automated-dns-configuration-on-aws/)
5. **Authentication**: Add SigV4 authentication policies for enhanced security.
