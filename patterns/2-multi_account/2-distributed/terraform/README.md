# Amazon VPC Lattice - Multi-Account: Distributed Service Networks (Terraform)

![Distributed Service Network](../../../../images/distributed.png)

## Prerequisites

- **Two AWS Accounts**: Service provider account and consumer account.
- **AWS Organizations**: All accounts must be part of the same AWS Organization.
- **Terraform**: >= 1.3.0 installed.
- **AWS CLI**: Configured with credentials for each account.
- **Permissions required** (per account):
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
# Navigate to the service account directory
cd service-account

# Configure AWS credentials for service provider account
export AWS_PROFILE=service-provider

# Update variables.tf or create terraform.tfvars with:
# - aws_region = "eu-west-1" (default - change if you want to use another region)

# Initialize Terraform
terraform init

# Review the planned changes
terraform plan

# Deploy the resources
terraform apply
```

### Step 2: Consumer Account - Deploy Service Network, VPCs, and Associations

**AWS Account**: Consumer Account

Deploy the service network, consumer VPCs, EC2 instances, and associations:

```bash
# Navigate to the consumer account directory
cd ../consumer-account

# Configure AWS credentials for consumer account
export AWS_PROFILE=consumer-account

# Update variables.tf or create terraform.tfvars with:
# - aws_region = "eu-west-1" (default - change if you want to use another region)

# Initialize Terraform
terraform init

# Review the planned changes
terraform plan

# Deploy the resources
terraform apply
```

## Cleanup

> **Important**: Delete resources in reverse order to avoid dependency issues.

### Step 1: Consumer Account

```bash
cd consumer-account
export AWS_PROFILE=consumer-account
terraform destroy
```

### Step 2: Service Provider Account

```bash
cd ../service-account
export AWS_PROFILE=service-provider
terraform destroy
```

## Account-Specific Documentation

For detailed technical documentation about each account's resources:

| Account | Documentation |
|---------|---------------|
| **Service Provider Account** | [service-account/README.md](./service-account/README.md) |
| **Consumer Account** | [consumer-account/README.md](./consumer-account/README.md) |

## Next Steps

After successfully deploying this pattern:

1. **Test connectivity**: Follow the testing guide to verify the service works correctly.
2. **Explore centralized pattern**: Try the [Centralized Service Network](../../1-centralized_service_network/) pattern for central network governance.
3. **Advanced architectures**: Explore [Advanced patterns](../../../3-advanced_architectures/) for more complex scenarios.
4. **Custom domains**: Implement custom domain names with Route 53 Private Hosted Zones (PHZs) and certificates. Implement automated DNS configuration using the [VPC Lattice DNS Guidance](https://aws.amazon.com/solutions/guidance/amazon-vpc-lattice-automated-dns-configuration-on-aws/)
5. **Authentication**: Add SigV4 authentication policies for enhanced security.
