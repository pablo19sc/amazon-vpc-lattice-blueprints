# Amazon VPC Lattice - Centralized VPC Endpoints (AWS CloudFormation)

CloudFormation implementation of the Centralized VPC Endpoints pattern. For the architecture, what gets deployed, and the connectivity testing steps, see the [pattern README](../README.md).

| Template | Stack | Resources |
|----------|-------|-----------|
| `centralized_endpoints.yaml` | `vpclattice-advanced-endpoints-provider` | Endpoints VPC, interface VPC endpoints, resource gateway, the resource configurations of both consumption models, and their access logging |
| `common.yaml` | `vpclattice-advanced-endpoints-common` | Common items: EC2 IAM role and instance profile |
| `consumer_group.yaml` | `vpclattice-advanced-endpoints-consumer-group` | Service network (and its access logging), group resource association, and consumer VPC of the group consumption model |
| `consumer_single.yaml` | `vpclattice-advanced-endpoints-consumer-single` | Service network (and its access logging), single resource associations, and consumer VPC of the single consumption model |

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
cd patterns/3-advanced_architectures/1-centralized_vpc_endpoints/cloudformation

# Deploy everything
make deploy

# Or deploy step-by-step:
make deploy-endpoints        # centralized VPC endpoints VPC and resource configurations
make deploy-common           # EC2 IAM role and instance profile
make deploy-consumer-group   # group consumption model (service network, consumer VPC and EC2 instance)
make deploy-consumer-single  # single consumption model (service network, consumer VPC and EC2 instance)
```

> **Note**: The VPC endpoints and the resource gateway are deployed in all the Availability Zones configured for the endpoints VPC, while each consumer VPC runs a single EC2 instance (one per consumption model). Keep this in mind when testing this environment from a cost perspective - for production environments, we recommend the use of at least 2 AZs for high-availability.

## Cleanup

```bash
# Delete everything
make undeploy
```

> **Note**: The access-logging CloudWatch Logs log groups (`/aws/vpclattice/<stack-name>/*`) are part of the stacks and are removed when the stacks are deleted — no manual cleanup is required.

## Observability: Access logging

This pattern enables VPC Lattice **access logging** by default, with one CloudWatch Logs log group per item (7-day retention, `<stack-name>` is the stack that owns it). The same connection is logged from two views: the service network owner's (which consumer VPC reached what through that service network) and the endpoints owner's (who reached the resource configurations, through any service network).

| Log group | Source |
|-----------|--------|
| `/aws/vpclattice/<consumer-group-stack>/service-network-group` | Group service network (`RESOURCE` log type) |
| `/aws/vpclattice/<consumer-single-stack>/service-network-single` | Single service network (`RESOURCE` log type) |
| `/aws/vpclattice/<provider-stack>/resource-config-group` | Group resource configuration |
| `/aws/vpclattice/<provider-stack>/resource-config-single` | All single resource configurations |

- **Where to find the logs**: CloudWatch Logs console → **Log groups**, or from the CLI:

  ```bash
  aws logs tail /aws/vpclattice/vpclattice-advanced-endpoints-consumer-group/service-network-group --follow
  ```

- **How to interpret them**: each entry records one connection (source VPC, resource configuration, resource gateway and resource IP/port) — Useful for observability of traffic to the centralized endpoints.

> **Cost note**: Access logging uses CloudWatch Logs vended-logs pricing (ingestion + storage). For this demo it is a small ongoing cost while the stacks are deployed.

## Testing

After deployment, follow the [Testing Connectivity](../README.md#testing-connectivity) steps in the pattern README to connect to each consumer instance (`InstanceId` output of each consumer stack) via Systems Manager and compare how both consumption models resolve AWS service endpoints.
