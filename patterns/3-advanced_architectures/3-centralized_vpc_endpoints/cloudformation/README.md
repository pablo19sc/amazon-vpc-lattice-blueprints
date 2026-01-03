# Amazon VPC Lattice - Centralized VPC Endpoints (AWS CloudFormation)

## Prerequisites

- **AWS Account**: With appropriate IAM permissions
- **AWS CLI**: Installed and configured with credentials
- **Permissions required**:
  - CloudFormation
  - VPC Lattice: Service networks, resource gateways, resource configurations
  - EC2: VPC, subnets, instances, security groups, VPC endpoints
  - IAM: Create roles and policies
- **Make**: Installed

## Deployment

```bash
# Clone the repository
git clone https://github.com/aws-samples/amazon-vpc-lattice-blueprints.git

# Navigate to the CloudFormation directory
cd patterns/3-advanced_architectures/3-centralized_vpc_endpoints/cloudformation

# Deploy everything
make deploy

# Or deploy step-by-step:
make deploy-endpoints  # centralized VPC endpoints VPC
make deploy-consumer   # consumer VPC and EC2 instances
```

> **Note**: EC2 instances and VPC endpoints will be deployed in all the Availability Zones configured for each VPC. Keep this in mind when testing this environment from a cost perspective - for production environments, we recommend the use of at least 2 AZs for high-availability.

## Cleanup

```bash
# Delete everything
make undeploy
```

## Next Steps

After successfully deploying this pattern:

1. **Test connectivity**: Verify EC2 instances can access AWS services through centralized endpoints.
2. **Add more endpoints**: Modify the CloudFormation templates to include additional AWS services.
3. **Scale consumers**: Deploy additional consumer VPCs to share the centralized endpoints.
4. **Production hardening**: Add monitoring, logging, and alerting for the centralized endpoints.
