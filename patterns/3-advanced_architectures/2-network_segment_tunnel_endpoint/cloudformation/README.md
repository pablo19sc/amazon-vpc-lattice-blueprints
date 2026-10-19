# Amazon VPC Lattice - Network Segment Access with Tunnel Endpoints (AWS CloudFormation)

CloudFormation implementation of the Network Segment Access pattern. For the architecture, what gets deployed, and the connectivity testing steps, see the [pattern README](../README.md).

## Prerequisites

- **AWS Account**: With appropriate IAM permissions
- **AWS CLI**: Installed and configured with credentials (also used to connect to the consumer instances during testing)
- **Make**: Installed
- **Permissions required**:
  - CloudFormation
  - VPC Lattice: Resource gateways, resource configurations, access log subscriptions
  - EC2: VPC, subnets, instances, security groups, VPC endpoints, EC2 Instance Connect endpoint
  - IAM and Lambda: a role and function for the custom resource that looks up the tunnel endpoint IPs
  - CloudWatch Logs: Log groups

## Deployment

```bash
# Clone the repository
git clone https://github.com/aws-samples/amazon-vpc-lattice-blueprints.git

# Navigate to the CloudFormation directory
cd patterns/3-advanced_architectures/2-network_segment_tunnel_endpoint/cloudformation

# Deploy everything
make deploy

# Or deploy step-by-step:
make deploy-provider  # provider VPC, segment hosts, resource gateway and CIDR resource configuration
make deploy-consumer  # consumer VPC, tunnel VPC endpoint and EC2 instances
```

The `make deploy-consumer` target reads the `ResourceConfigurationArn` and `NetworkSegmentCidrs` outputs from the `vpclattice-tunnel-provider` stack and passes them to the consumer stack as parameters. It needs `CAPABILITY_IAM`, because the consumer stack creates the IAM role of the custom resource (`Custom::TunnelEndpointIps`) that looks up the tunnel endpoint's per-AZ IP addresses for the instances' user data.

All stacks deploy to `eu-west-1` by default; edit the `--region` value in the `Makefile` to use a different Region.

> **Note**: The VPCs, the segment hosts and the consumer instances are deployed across both Availability Zones. Keep this in mind when testing this environment from a cost perspective - for production environments, we recommend the use of at least 2 AZs for high-availability.

## Cleanup

```bash
# Delete everything
make undeploy
```

> **Note**: The consumer stack is deleted first, so the tunnel endpoint is gone before the resource configuration it uses. The access-logging CloudWatch Logs log group (`/aws/vpclattice/<stack-name>`) is part of the provider stack and is removed with it — no manual cleanup is required.

## Observability: Access logging

This pattern enables VPC Lattice **access logging** by default. An access log subscription on the resource configuration sends a log entry for each connection to the network segment to a CloudWatch Logs log group named `/aws/vpclattice/<stack-name>` (7-day retention), created as part of the provider stack.

```bash
aws logs tail /aws/vpclattice/vpclattice-tunnel-provider --follow
```

> **Cost note**: This pattern runs EC2 instances in both VPCs and a tunnel VPC endpoint (hourly + per GB processed), the resource gateway charges per GB processed, and access logging uses CloudWatch Logs vended-logs pricing (ingestion + storage). Tear the stacks down with `make undeploy` when you are done.

## Testing

After successful deployment, follow the [Testing Connectivity](../README.md#testing-connectivity) steps in the pattern README. The consumer stack outputs the instance IDs, and the provider stack outputs the segment host IPs (`SegmentHostA` / `SegmentHostB`).
