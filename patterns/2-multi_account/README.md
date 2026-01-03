# Amazon VPC Lattice Blueprints - Multi-Account Architectures

## Overview

This pattern demonstrates how Amazon VPC Lattice operates in multi-account environments using [AWS Resource Access Manager](https://docs.aws.amazon.com/ram/latest/userguide/what-is.html) (RAM) to share **service networks** and **services** across accounts.

**Use this pattern to**:

- Understand multi-account VPC Lattice deployments.
- Learn how to share service networks and services using AWS RAM.
- Implement centralized or distributed network management patterns.
- Choose the right governance model for your organization.
- Build a foundation for enterprise-scale architectures.

> **Note**: DNS resolution in multi-account environments with custom domain names is not covered in these examples, as we use VPC Lattice-generated domain names. For automated DNS configuration across accounts with custom domains, refer to the [Amazon VPC Lattice Automated DNS Configuration Guidance](https://aws.amazon.com/solutions/guidance/amazon-vpc-lattice-automated-dns-configuration-on-aws/).

## Architecture Patterns

This section includes two distinct multi-account patterns demonstrating different governance models:

| Pattern | Description | IaC Support |
|---------|-------------|-------------|
| [1. Centralized Service Network](./1-centralized_service_network/) | Central account owns service network; spoke accounts create services and VPC associations | CloudFormation, Terraform |
| [2. Distributed Service Networks](./2-distributed/) | Service accounts create and share services; consumer accounts own their service networks | CloudFormation, Terraform |

### Common Architecture Components

Both patterns share these core components to maintain consistency and simplify comparison:

| Component | Configuration |
|-----------|---------------|
| **AWS Region** | eu-west-1 (configurable) |
| **Consumer VPC** | VPC with EC2 instances (1 per AZ) and EC2 Instance Connect endpoint for secure access |
| **VPC Lattice Service** | Service with HTTPS listener (port 443) forwarding to Lambda function target |

> **Note on RAM Sharing**: All RAM resource shares in these examples are configured to share resources with the entire AWS Organization for simplicity. For production environments and granular access control, it is recommended to share resources only with specific AWS Account IDs that need to perform actions with these resources. This follows the principle of least privilege and reduces the attack surface.

**Key Differences Between Patterns**:

- **Service Network Ownership**: Centralized (network account) vs. Distributed (consumer account)
- **Resource Sharing**: Different RAM sharing directions and dependencies.
- **Governance Model**: Centralized control vs. consumer autonomy.

---

## 1. Centralized Service Network(s)

In this pattern, a central AWS Account owns and manages the VPC Lattice service network, while spoke AWS Accounts create services and associate their VPCs to the shared service network. This approach provides centralized governance while enabling distributed service ownership.

![Centralized Service Network](../../images/centralized.png)

### Account Structure

| Account Type | Responsibilities | Key Resources |
|--------------|------------------|---------------|
| **Network Account (Central)** | Owns and manages service network infrastructure | Service network, RAM shares, service associations |
| **Service Provider Account** | Creates and shares VPC Lattice services | Services, Lambda functions, RAM shares |
| **Consumer Account** | Associates VPCs to consume services | VPCs, VPC associations, EC2 instances |

### Implementation

| IaC Tool | Location |
|----------|----------|
| **CloudFormation** | [`./1-centralized_service_network/cloudformation/`](./1-centralized_service_network/cloudformation/) |
| **Terraform** | [`./1-centralized_service_network/terraform/`](./1-centralized_service_network/terraform/) |

### Testing Connectivity

<details>
<summary>Click to expand testing steps</summary>

> **Note**: Steps 1-3 are performed in the **Consumer AWS Account**, Step 4 in the **Service Provider AWS Account**, and Step 5 in the **Network AWS Account (Central)**.

#### Step 1: Connect to Consumer Instance (Consumer Account)

Use EC2 Instance Connect endpoint to access a consumer instance:

> **Note**: Consumer EC2 instance IDs are provided as outputs when deploying the CloudFormation or Terraform code. Check the deployment outputs to get the instance IDs.

```bash
aws ec2-instance-connect ssh --instance-id <consumer-instance-id>
```

#### Step 2: Test DNS Resolution (Consumer Account)

Verify VPC Lattice DNS resolution:

> **Note**: The service domain name is provided as an output when deploying the CloudFormation or Terraform code. Check the deployment outputs to get the exact domain name.

```bash
dig <service-domain-name>
```

**Expected Result**: Link-local address (169.254.171.X) indicating VPC Lattice routing

#### Step 3: Test HTTPS Connectivity (Consumer Account)

Test connectivity to the Lambda function through VPC Lattice:

```bash
curl https://<service-domain-name>
```

**Expected Response** (JSON format):
```json
{
  "message": "Hello from Lambda Function!!"
}
```

#### Step 4: Verify Service and Target Group (Service Provider Account)

Check that the VPC Lattice service and target group are created:

1. Navigate to **VPC → VPC Lattice → Services**
2. Verify the VPC Lattice service is created and shows **"Active"** status
3. Navigate to **VPC → VPC Lattice → Target groups**
4. Select the Lambda target group
5. Verify the Lambda function is registered as a target

#### Step 5: Verify Service Network Associations (Network Account - Central)

Check that VPC and service associations are active:

1. Navigate to **VPC → VPC Lattice → Service networks**
2. Select the service network
3. In the **Associations** tab, verify:
   - **VPC associations**: Consumer VPC shows **"Active"** status
   - **Service associations**: VPC Lattice service shows **"Active"** status

</details>

---

## 2. Distributed Service Networks

In this pattern, service provider accounts create and share services, while consumer accounts own their own service networks and decide which services to consume. This approach provides maximum flexibility and autonomy for consumer accounts.

![Distributed Service Network](../../images/distributed.png)

### Account Structure

| Account Type | Responsibilities | Key Resources |
|--------------|------------------|---------------|
| **Service Provider Account** | Creates and shares VPC Lattice services | Services, Lambda functions, RAM shares |
| **Consumer Account** | Owns service network and consumes services | Service network, VPCs, VPC associations, service associations, EC2 instances |

### Implementation

| IaC Tool | Location |
|----------|----------|
| **CloudFormation** | [`./2-distributed/cloudformation/`](./2-distributed/cloudformation/) |
| **Terraform** | [`./2-distributed/terraform/`](./2-distributed/terraform/) |

### Testing Connectivity

<details>
<summary>Click to expand testing steps</summary>

> **Note**: Steps 1-3 are performed in the **Consumer AWS Account**, and Step 4 in the **Service Provider AWS Account**.

#### Step 1: Connect to Consumer Instance (Consumer Account)

Use EC2 Instance Connect endpoint to access a consumer instance:

> **Note**: Consumer EC2 instance IDs are provided as outputs when deploying the CloudFormation or Terraform code. Check the deployment outputs to get the instance IDs.

```bash
aws ec2-instance-connect ssh --instance-id <consumer-instance-id>
```

#### Step 2: Test DNS Resolution (Consumer Account)

Verify VPC Lattice DNS resolution:

> **Note**: The service domain name is provided as an output when deploying the CloudFormation or Terraform code. Check the deployment outputs to get the exact domain name.

```bash
dig <service-domain-name>
```

**Expected Result**: Link-local address (169.254.171.X) indicating VPC Lattice routing

#### Step 3: Test HTTPS Connectivity (Consumer Account)

Test connectivity to the Lambda function through VPC Lattice:

```bash
curl https://<service-domain-name>
```

**Expected Response** (JSON format):
```json
{
  "message": "Hello from Lambda Function!!"
}
```

#### Step 4: Verify Service and Target Group (Service Provider Account)

Check that the VPC Lattice service and target group are created:

1. Navigate to **VPC → VPC Lattice → Services**
2. Verify the VPC Lattice service is created and shows **"Active"** status
3. Navigate to **VPC → VPC Lattice → Target groups**
4. Select the Lambda target group
5. Verify the Lambda function is registered as a target

> **Note**: Lambda targets do not display health status in VPC Lattice. Successful connectivity testing in Step 3 confirms the Lambda integration is working correctly.

</details>

---

## Choosing Between Patterns

| Consideration | Centralized | Distributed |
|---------------|-------------|-------------|
| **Governance Model** | Central team controls network | Consumers control their networks |
| **Policy Management** | Centralized, consistent policies | Decentralized, flexible policies |
| **Operational Overhead** | Lower for consumers | Higher for consumers |
| **Service Discovery** | Managed by central team | Managed by each consumer |
| **Scalability** | Easy to add accounts | Each consumer scales independently |
| **Best For** | Organizations with strong central networking teams | Organizations with autonomous application teams |

## Deployment Considerations

Both patterns use AWS RAM for resource sharing:

| Shared Resource | Sharing Direction | Pattern |
|-----------------|-------------------|---------|
| **Service Network** | Network Account → Consumer Accounts | Centralized |
| **VPC Lattice Service** | Service Account → Network Account | Centralized |
| **VPC Lattice Service** | Service Account → Consumer Accounts | Distributed |

- All accounts must be part of the same AWS Organization.
- RAM sharing is automatically accepted within the organization.

---

## Best Practices

### Security & Encryption

Ensure secure communication and access control across all accounts:

| Practice | Implementation |
|----------|----------------|
| **TLS Encryption** | Use HTTPS listeners with custom domain names and ACM certificates for all production services |
| **Authentication** | Implement SigV4 authentication policies to restrict access to trusted consumers |
| **IAM Policies** | Apply least-privilege principles across all accounts and resources |

### Network Configuration

Configure networking components for reliable multi-account connectivity:

| Practice | Implementation |
|----------|----------------|
| **DNS Settings** | Enable DNS resolution and hostnames in all VPCs |
| **Security Groups** | Configure security groups to allow required traffic between resources and VPC Lattice |
| **Health Monitoring** | Regularly verify target health status and service availability |

### Multi-Account Operations

Streamline operations across multiple AWS accounts:

| Practice | Implementation |
|----------|----------------|
| **AWS Organizations** | Use AWS Organizations for automatic RAM share acceptance and centralized management |
| **Resource Tagging** | Implement consistent tagging strategy for cost allocation and resource tracking |
| **Access Logging** | Enable VPC Lattice access logs for monitoring, troubleshooting, and compliance |
| **Documentation** | Maintain clear documentation of account relationships, ownership, and dependencies |
| **Infrastructure as Code** | Use CloudFormation or Terraform for consistent, repeatable, and auditable deployments |

### Governance & Compliance

Establish governance policies for enterprise-scale deployments:

| Practice | Implementation |
|----------|----------------|
| **Ownership Model** | Define clear ownership boundaries between network, service provider, and consumer teams |
| **Sharing Policies** | Create consistent policies for service creation, sharing, and consumption |
| **Cost Management** | Track and allocate costs per account, service, and consumer |
| **Service Control Policies** | Use AWS Organizations SCPs for additional security and compliance controls |
| **Regular Audits** | Periodically review resource shares, associations, and access patterns |

## Troubleshooting

### RAM Share Issues

**Check**:

1. Share is created and active.
2. Correct account IDs in share.
3. Share invitation accepted (if required)
4. IAM permissions allow resource access.

### Cross-Account Connectivity Issues

**Check**:

1. Service association is active.
2. VPC association is active.
3. Security groups allow traffic.

### DNS Resolution Issues

**Check**:

1. VPC has DNS resolution and hostnames enabled.
2. Service domain name is correct.

## Next Steps

After mastering these multi-account architectures:

1. **Test connectivity**: Follow the testing guide to verify the service works correctly.
2. **Explore distributed pattern**: Try the distributed service networks pattern.
3. **Advanced architectures**: Explore [Advanced patterns](../../../3-advanced\_architectures/) for more complex scenarios.
4. **Custom domains**: Implement custom domain names with Route 53 Private Hosted Zones (PHZs) and certificates. Implement automated DNS configuration using the [VPC Lattice DNS Guidance](https://aws.amazon.com/solutions/guidance/amazon-vpc-lattice-automated-dns-configuration-on-aws/)
5. **Authentication**: Add SigV4 authentication policies for enhanced security.
