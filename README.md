# Amazon VPC Lattice Blueprints

Welcome to Amazon VPC Lattice Blueprints!

This project contains a collection of Amazon VPC Lattice patterns implemented in [AWS CloudFormation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html) and [Terraform](https://developer.hashicorp.com/terraform) that demonstrate how to configure and deploy application networking using [Amazon VPC Lattice](https://aws.amazon.com/vpc/lattice/).

## Motivation

Amazon VPC Lattice simplifies service-to-service communication by providing a fully managed application networking service that connects, secures, and monitors services across multiple accounts and VPCs. While VPC Lattice eliminates the need to manage load balancers, proxies, or complex networking configurations, understanding all the service's capabilities can be overwhelming, especially when designing production-grade architectures.

AWS customers have asked for practical examples and best practices that demonstrate how to leverage VPC Lattice's full potential. These blueprints provide real-world use cases with complete, tested implementations that teams can use for:

- **Proof of Concepts (PoCs)**: Quickly validate VPC Lattice capabilities in your environment.
- **Testing and learning**: Understand how different features work together through hands-on examples.
- **Starting point**: Use as a foundation for your application networking configurations.
- **Best practices**: Learn recommended patterns for common service-to-service communication scenarios.

With VPC Lattice Blueprints, customers can configure and deploy service-to-service architectures at scale in days, rather than spending weeks or months figuring out the optimal configuration.

## Consumption

Amazon VPC Lattice Blueprints have been designed to be consumed in the following manners:

1. **Reference**: Users can refer to the patterns and snippets provided to help guide them to their desired solution. Users will typically view how the pattern or snippet is configured to achieve the desired end result and then replicate that in their environment.

2. **Copy & Paste**: Users can copy and paste the patterns and snippets into their own environment, using VPC Lattice Blueprints as the starting point for their implementation. Users can then adapt the initial pattern to customize it to their specific needs.

**Amazon VPC Lattice Blueprints are not intended to be consumed as-is directly from this project**. The patterns provided only contain `variables` when certain information is required to deploy the pattern and generally use local variables. If you wish to deploy the patterns into a different AWS Region or with other changes, it is recommended that you make those modifications locally before applying the pattern.

## Patterns

| Pattern | Description | IaC Support |
|---------|-------------|-------------|
| [1. Simple Architectures](./patterns/1-simple_architectures/) | Basic VPC Lattice setup demonstrating different target types | CloudFormation, Terraform |
| [2. Multi-AWS Account](./patterns/2-multi_account/) | Cross-account VPC Lattice deployment with AWS RAM sharing | CloudFormation, Terraform |
| [3. Advanced Architectures](./patterns/3-advanced_architectures/) | Complex architectures including hybrid connectivity, cross-Region, and advanced connectivity patterns | CloudFormation, Terraform |
| 4. Auth Policies & Signing | Authentication and authorization examples | Coming Soon |

## Infrastructure as Code Considerations

Amazon VPC Lattice Blueprints do not intend to teach users the recommended practices for Infrastructure as Code (IaC) tools nor does it offer guidance on how users should structure their IaC projects. The patterns provided are intended to show users how they can achieve a defined architecture or configuration in a way that they can quickly and easily get up and running to start interacting with that pattern. Therefore, there are a few considerations users should be aware of when using VPC Lattice Blueprints:

1. We recognize that most users will already have existing VPCs in separate IaC projects or stacks. However, the patterns provided come complete with VPCs to ensure stable, deployable examples that have been tested and validated.

2. Patterns are not intended to be consumed in-place in the same manner that one would consume a reusable module. Therefore, we do not provide extensive parameters and outputs to expose various levels of configuration for the examples. Users can modify the pattern locally after cloning to suit their requirements.

3. The patterns use local variables (Terraform) or parameters (CloudFormation) with sensible defaults. If you wish to deploy patterns into different regions or with other changes, modify these values before deploying.

4. For production deployments, we recommend separating your infrastructure into multiple projects or stacks (e.g., network infrastructure, application services, monitoring resources) to follow IaC best practices and enable independent lifecycle management.

## Amazon VPC Lattice Fundamentals

[Amazon VPC Lattice](https://docs.aws.amazon.com/vpc-lattice/latest/ug/what-is-vpc-lattice.html) is a fully managed application networking service that you use to connect, secure, and monitor services across multiple accounts and VPCs. VPC Lattice simplifies connectivity between your services by eliminating the need to manage load balancers, proxies, or complex networking configurations.

### Key Advantages

| Capability | Description |
|------------|-------------|
| **Simplified Connectivity** | Eliminate complex networking configurations |
| **Multi-Account Support** | Seamless service communication across AWS accounts |
| **Built-in Security** | Fine-grained access control with auth policies |
| **Comprehensive Observability** | Centralized monitoring and access logging |

---

### Service Networks

A [service network](https://docs.aws.amazon.com/vpc-lattice/latest/ug/service-networks.html) is the core construct in VPC Lattice that enables connectivity between services and clients.

| Characteristic | Description |
|----------------|-------------|
| **Function** | Logical boundary for a collection of services |
| **Cross-Account Sharing** | Supported via [AWS Resource Access Manager (RAM)](https://docs.aws.amazon.com/vpc-lattice/latest/ug/sharing.html) |
| **Access Control** | Fine-grained control through [auth policies](https://docs.aws.amazon.com/vpc-lattice/latest/ug/auth-policies.html) |
| **Monitoring** | [Centralized observability](https://docs.aws.amazon.com/vpc-lattice/latest/ug/service-network-monitoring.html) for all associated services |

---

### Services

A VPC Lattice [service](https://docs.aws.amazon.com/vpc-lattice/latest/ug/services.html) represents an application or microservice that you want to make available to clients within your service network.

| Aspect | Details |
|--------|---------|
| **Identification** | Unique DNS name or [custom domain name](https://docs.aws.amazon.com/vpc-lattice/latest/ug/service-custom-domain-name.html) |
| **Supported Targets** | EC2 instances, Auto-scaling groups, Lambda functions, IP-based targets (ECS and EKS clusters included) |
| **Load Balancing** | Built-in capabilities with health checks |
| **Listener Protocols** | HTTP, HTTPS, gRPC, TLS pass-through |
| **TLS** | Termination and [certificate management](https://docs.aws.amazon.com/vpc-lattice/latest/ug/service-byoc.html) |

---

### VPC Resources

For applications that require TCP connectivity, VPC Lattice enables the consumption of [VPC resources](https://docs.aws.amazon.com/vpc-lattice/latest/ug/vpc-resources.html) from a service network.

| Resource Type | Description |
|---------------|-------------|
| **Identification** | Unique DNS name or [custom domain name](https://docs.aws.amazon.com/vpc-lattice/latest/ug/resource-configuration.html#custom-domain-name-resource-providers) |
| **Supported Targets** | Native AWS resources ([Amazon RDS](https://aws.amazon.com/rds/)), domain names, IP addresses |
| **Sharing** | Supported via AWS RAM to specify principals |
| **Automated DNS configuration** | VPC Lattice can manage Route 53 private hosted zones (PHZs) in consumer VPCs for custom domain names; consumers control which domains are allowed via DNS preferences |

#### DNS Configuration

Resource consumers have [granular control](https://docs.aws.amazon.com/vpc-lattice/latest/ug/resource-configuration.html#custom-domain-name-resource-consumers) over which domains VPC Lattice can manage PHZs for in their VPCs.

| DNS Preference | Description |
|----------------|-------------|
| **VERIFIED_DOMAINS_ONLY** | (Recommended) VPC Lattice provisions private hosted zones only for verified custom domain names |
| **ALL_DOMAINS** | VPC Lattice provisions private hosted zones for all custom domain names regardless of verification status |
| **VERIFIED_DOMAINS_AND_SPECIFIED_DOMAINS** | VPC Lattice provisions zones for verified domains plus consumer-specified domains |
| **SPECIFIED_DOMAINS_ONLY** | VPC Lattice provisions zones only for consumer-specified domains |

> **Note**: When private DNS is enabled, all traffic to the custom domain from the consumer's VPC is routed through VPC Lattice. Use `VERIFIED_DOMAINS_ONLY` to maintain a strong security posture.

---

### Associations and Endpoints

Communication in VPC Lattice is enabled by connecting both consumers and producers to a service network.

#### Service Associations

| Aspect | Details |
|--------|---------|
| **Purpose** | Expose VPC Lattice services via [service association](https://docs.aws.amazon.com/vpc-lattice/latest/ug/service-associations.html) |
| **Result** | Service becomes discoverable and accessible to clients |

#### VPC Associations

| Aspect | Details |
|--------|---------|
| **Purpose** | Enable consumers in a VPC via [VPC association](https://docs.aws.amazon.com/vpc-lattice/latest/ug/service-network-associations.html#service-network-vpc-associations) |
| **Infrastructure** | VPC Lattice creates necessary networking infrastructure |
| **Scope** | Enables connectivity only for consumers in that VPC |

#### Service Network Endpoints

| Aspect | Details |
|--------|---------|
| **Purpose** | Allow on-premises or cross-Region resources to connect |
| **Use Case** | [Service network endpoint](https://docs.aws.amazon.com/vpc-lattice/latest/ug/service-network-associations.html#service-network-vpc-endpoint-associations) for routable networks (hybrid or cross-Region) |

---

### Listeners and Targets

VPC Lattice services use listeners and target groups to route traffic from clients to backend targets.

#### Listeners

[Listeners](https://docs.aws.amazon.com/vpc-lattice/latest/ug/listeners.html) define how your service accepts incoming requests.

| Protocol | Details |
|----------|---------|
| **HTTP** | Standard HTTP traffic |
| **HTTPS** | VPC Lattice provisions and manages TLS certificate for generated FQDN; use [AWS Certificate Manager](https://aws.amazon.com/certificate-manager/) (ACM) for custom domains |
| **TLS** | TLS passthrough - application decrypts traffic |

**Additional Details:**
- VPC Lattice supports TLS on HTTP/1.1 and HTTP/2
- Listener and target don't require matching protocols

#### Target Groups

[Target groups](https://docs.aws.amazon.com/vpc-lattice/latest/ug/target-groups.html) define where traffic is routed after it's received by a listener.

| Target Type | Description | Notes |
|-------------|-------------|-------|
| **EC2 Instances** | Identified by instance ID | Used when associating Auto Scaling groups |
| **IP Addresses** | Within VPC CIDR range | Cannot register VPC endpoints or publicly routable IPs; supports ECS tasks and EKS pods (via [AWS Gateway API Controller](https://www.gateway-api-controller.eks.aws.dev/latest/)) |
| **Lambda Functions** | Serverless compute | Direct integration |
| **Application Load Balancers** | Existing ALBs | Reuse existing load balancing infrastructure |

**Supported Protocols:** HTTP, HTTPS, TCP (only for TLS listeners)

---

### Security and Observability

#### Auth Policies

[Auth policies](https://docs.aws.amazon.com/vpc-lattice/latest/ug/auth-policies.html) control who can access services within a service network.

| Aspect | Details |
|--------|---------|
| **Scope** | Service network and individual service levels |
| **Granularity** | Fine-grained access control |
| **Format** | [Resource-based policies](https://docs.aws.amazon.com/vpc-lattice/latest/ug/auth-policies.html#auth-policies-resource-format) |
| **Condition Keys** | [Supported condition keys](https://docs.aws.amazon.com/vpc-lattice/latest/ug/auth-policies.html#auth-policies-condition-keys) for policy evaluation |

#### Access Logging

VPC Lattice provides comprehensive [access logging](https://docs.aws.amazon.com/vpc-lattice/latest/ug/monitoring-access-logs.html) capabilities.

| Log Information | Description |
|-----------------|-------------|
| **Request Metadata** | Timestamp, client IP, request path, HTTP method |
| **Response Information** | Status code, processing time |
| **Authentication Details** | Auth-related information |
| **Headers** | Request and response headers |

**Log Destinations:** [Amazon S3](https://aws.amazon.com/pm/serv-s3/), [Amazon CloudWatch Logs](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/WhatIsCloudWatchLogs.html), [Amazon Data Firehose](https://aws.amazon.com/firehose/)

**Scope:** Service network and service level

## Prerequisites

Before using these blueprints, you should have:

- **AWS Networking Knowledge**: Understanding of VPCs, subnets, security groups, and service-to-service communication patterns.
- **Application Networking Concepts**: Familiarity with load balancing, service discovery, and application layer protocols.
- **Infrastructure as Code**: Experience with AWS CloudFormation or Terraform.
- **AWS Account**: An AWS account with appropriate IAM permissions to create networking resources.

## Support & Feedback

Amazon VPC Lattice Blueprints are maintained by AWS Solution Architects. This is not part of an AWS service and support is provided as best-effort by the VPC Lattice Blueprints community. To provide feedback, please use the [issues templates](https://github.com/aws-samples/amazon-vpc-lattice-blueprints/issues) provided. If you are interested in contributing to VPC Lattice Blueprints, see the [Contribution guide](CONTRIBUTING.md).

## FAQ

**Q: Why do some patterns show "Coming Soon"?**

A: We're actively developing the blueprint library. We've structured the repository to show the planned patterns while we work on completing them. See [CONTRIBUTING](./CONTRIBUTING.md) to provide feedback or request new patterns.

**Q: Can I use these patterns in production?**

A: These patterns are **not ready** for production environments. They should be customized for your specific requirements. Update variables, CIDR blocks, and configurations before deploying to production. Always test in pre-production environments first.

**Q: Do I need separate AWS accounts to use these patterns?**

A: No, most patterns can be deployed in a single AWS account. However, the [Multi-AWS Account pattern](./patterns/2-multi_account/) demonstrates cross-account deployment using AWS Resource Access Manager (RAM).

**Q: Which IaC tool should I use?**

A: Both CloudFormation and Terraform are supported for most patterns. Choose based on your organization's preferences and existing tooling. Terraform patterns use the [AWS](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) and [AWSCC](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs) providers, while CloudFormation patterns use native AWS resources.

**Q: What are the differences between VPC Lattice and Application Load Balancer?**

A: VPC Lattice is designed for service-to-service communication across VPCs and accounts, while ALB is designed for client-to-application traffic. VPC Lattice provides built-in service discovery, cross-account sharing, and simplified connectivity without managing network infrastructure. ALB is better suited for internet-facing or VPC-internal application load balancing.

## Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See [LICENSE](LICENSE).
