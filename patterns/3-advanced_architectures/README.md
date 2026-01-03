# Amazon VPC Lattice Blueprints - Advanced Architectures

## Overview

This section demonstrates advanced Amazon VPC Lattice patterns that go beyond standard service-to-service connectivity. These patterns address real-world use cases and enterprise scenarios where VPC Lattice can solve complex networking challenges in innovative ways.

**Use this section to**:

- Explore practical applications of VPC Lattice beyond basic service connectivity.
- Discover how VPC Lattice can address specific business and technical challenges.
- Learn implementation patterns for complex enterprise requirements.
- Understand how to adapt VPC Lattice to unique architectural needs.

> **Note**: These patterns assume familiarity with VPC Lattice basics. If you're new to VPC Lattice, start with [Simple Architectures](../1-simple_architectures/) and [Multi-Account Patterns](../2-multi_account/).

## Architecture Patterns

This section includes advanced patterns for enterprise deployments:

| Pattern | Description | IaC Support |
|---------|-------------|-------------|
| 1. Cross-Region | Multi-region VPC Lattice deployments and service connectivity | Coming Soon |
| 2. Hybrid Connectivity | Connect on-premises networks to VPC Lattice services via AWS Direct Connect or Site-to-Site VPN | Coming Soon |
| [3. Centralized VPC Endpoints](./3-centralized_vpc_endpoints/) | Centralized VPC endpoints shared across multiple consumer VPCs through VPC Lattice | CloudFormation, Terraform |

---

## 1. Cross-Region

This pattern demonstrates how to deploy VPC Lattice across multiple AWS Regions, enabling global service connectivity and disaster recovery architectures.

**Status**: Coming Soon

---

## 2. Hybrid Connectivity

This pattern demonstrates how to connect on-premises networks to VPC Lattice services, enabling hybrid cloud architectures where on-premises applications can consume cloud services.

**Status**: Coming Soon

---

## 3. Centralized VPC Endpoints

This pattern demonstrates how to centralize VPC endpoints in a shared services VPC and make them accessible to multiple consumer VPCs through VPC Lattice. This approach reduces costs by eliminating the need for duplicate VPC endpoints in each consumer VPC while simplifying endpoint management.

The pattern leverages **VPC Lattice Resources** with custom domain names and automated DNS configuration controls to automatically resolve VPC endpoint domain names (e.g., `ssm.eu-west-1.amazonaws.com`) to point to the Resource Association domain name. The implementation includes DNS controls that allow only `*.amazonaws.com` domains, ensuring secure and controlled access to centralized endpoints.

### What gets deployed

| Component | Details |
|-----------|---------|
| **VPC Endpoints VPC** | Centralized VPC hosting interface VPC endpoints for AWS services (SSM, SSM Messages, EC2 Messages, STS) |
| **Consumer VPC** | VPC with EC2 instances consuming AWS services through centralized endpoints |
| **VPC Lattice Service Network** | Service network connecting consumer VPC to centralized endpoints |
| **VPC Lattice Resource Gateway** | Resource gateway enabling VPC Lattice to route traffic to VPC endpoints |
| **VPC Lattice Resource Configurations** | Resource configurations with custom domain names for each VPC endpoint |
| **VPC Lattice Resource Associations** | Resource associations connecting configurations to the service network with automated DNS resolution |

### Implementation

| IaC Tool | Location |
|----------|----------|
| **CloudFormation** | [`./3-centralized_vpc_endpoints/cloudformation/`](./3-centralized_vpc_endpoints/cloudformation/) |
| **Terraform** | [`./3-centralized_vpc_endpoints/terraform/`](./3-centralized_vpc_endpoints/terraform/) |

### Testing Connectivity

<details>
<summary>Click to expand testing steps</summary>

#### Step 1: Connect to Consumer Instance via Systems Manager

Use AWS Systems Manager Session Manager to connect to a consumer EC2 instance. The fact that you can successfully establish a Session Manager connection already demonstrates that the centralized VPC endpoints are working, as Session Manager requires connectivity to the SSM, SSM Messages, and EC2 Messages endpoints.

> **Note**: Consumer EC2 instance IDs are provided as outputs when deploying the CloudFormation or Terraform code.

```bash
aws ssm start-session --target <consumer-instance-id> --region <your-region>
```

**Expected Result**: Session Manager successfully connects to the instance.

#### Step 2: Verify DNS Resolution for Centralized Endpoints

Once connected to the consumer instance, verify that AWS service endpoints resolve to VPC Lattice link-local addresses:

```bash
# Test DNS resolution for SSM endpoint
dig +short ssm.<your-region>.amazonaws.com

# Test DNS resolution for EC2 Messages endpoint
dig +short ec2messages.<your-region>.amazonaws.com

# Test DNS resolution for STS endpoint
dig +short sts.<your-region>.amazonaws.com
```

**Expected Result**: Each command returns link-local addresses in the `129.224.0.x/17` range, indicating VPC Lattice is handling the DNS resolution and routing

Example output:
```
129.224.0.123
129.224.171.124
```

#### Step 3: Test STS Endpoint Connectivity

Verify connectivity to the AWS Security Token Service (STS) through the centralized endpoint:

```bash
# Get caller identity using STS
aws sts get-caller-identity --region <your-region>
```

**Expected Result**: Command returns the IAM role information for the EC2 instance

Example output:
```json
{
    "UserId": "AIDACKCEVSQ6C2EXAMPLE:i-1234567890abcdef0",
    "Account": "123456789012",
    "Arn": "arn:aws:sts::123456789012:assumed-role/ec2_ssm_role/i-1234567890abcdef0"
}
```

</details>

---

## Troubleshooting

### Cross-Region Issues

**Check**:

1. Service networks exist in both regions
2. DNS resolution works across regions
3. Security groups allow cross-region traffic
4. Route 53 health checks are passing

### Hybrid Connectivity Issues

**Check**:

1. Direct Connect or VPN connection is active
2. Transit Gateway routes are configured correctly
3. On-premises DNS can resolve VPC Lattice services
4. Security groups and NACLs allow on-premises traffic
5. BGP routes are properly advertised

### Centralized Endpoint Issues

**Check**:

1. VPC endpoints are in "Available" state
2. VPC Lattice services are associated with service network
3. Consumer VPCs are associated with service network
4. Security groups allow traffic to VPC endpoints
5. DNS resolution returns link-local addresses

## Next Steps

After mastering these advanced architectures:

1. **Combine Patterns**: Integrate multiple patterns for comprehensive solutions.
2. **Production Hardening**: Add monitoring, logging, and alerting.
3. **Automation**: Implement CI/CD pipelines for infrastructure deployment.
4. **Security Enhancement**: Implement advanced security controls and compliance measures
6. **Custom Domain Names**: Configure custom domains with Route 53 and ACM certificates. Implement automated DNS configuration using the [VPC Lattice DNS Guidance](https://aws.amazon.com/solutions/guidance/amazon-vpc-lattice-automated-dns-configuration-on-aws/)
