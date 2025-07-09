# Amazon VPC Lattice Blueprints

Welcome to the Amazon VPC Lattice Blueprints!

This project offers practical guidance for deploying [Amazon VPC Lattice](https://aws.amazon.com/vpc/lattice/), featuring real-world examples and full end-to-end deployment code. These blueprints complement AWS documentation and AWS blogs by expanding on concepts with complete implementations in various Infrastructure as Code (IaC) languages.

Designed for network and application architects, the blueprints demonstrate how to effectively connect, secure, and monitor services across multiple accounts and VPCs using Amazon VPC Lattice. The examples assume a solid understanding of AWS networking concepts including VPCs, subnets, security groups, as well as service-to-service communication patterns and application networking principles.

The guide covers various architectures, from simple patterns showing the different targets the service supports to complex architectures (hybrid and cross-Region) and cross-Account patterns.

## Table of Content

- [Consumption](#consumption)
- [Patterns](#patterns)
- [Amazon VPC Lattice components and features](#amazon-vpc-lattice-components-and-features)
  - [Service Networks](#service-networks)
  - [Services](#services)
  - [VPC resources](#vpc-resources)
  - [Associations and endpoints](#associations-and-endpoints)
  - [Listeners and targets](#listeners-and-targets)
  - [Security and observability](#security-and-observability)
- [FAQ](#faq)
- [Authors](#authors)
- [Contributing](#contributing)
- [License](#license)

## Consumption

These blueprints have been designed to be consumed in the following manners:

* **Reference Architecture**. You can use the examples and patterns provided as a guide to build your target architecture. From the architectures (and code provided) you can review and test the specific architecture and use it as reference to replicate in your environment.
* **Copy & paste**. You can do a quick copy-and-paste of a specific architecture snippet into your own environment, using the blueprints as the starting point for your implementation. You can then adapt the initial pattern to customize it to your specific needs. Of course, we recommend to deploy first in pre-production and have a controlled rollout to production environments after enough testing. 

**The VPC Lattice blueprints are not intended to be consumed as-is directly from this project**. The patterns provided will use local variables (as defaults or required to be provided by you) that we recommend you change when deploying in your pre-production or testing environments.

## Patterns

1. [Simple architectures](./patterns/1-simple_architectures/)
2. [Multi-account](./patterns/2-multi_account/)
3. Advanced architectures (TBD)
4. Auth policies & signing (TBD)

## Amazon VPC Lattice components and features

[Amazon VPC Lattice](https://docs.aws.amazon.com/vpc-lattice/latest/ug/what-is-vpc-lattice.html) is a fully managed application networking service that you use to connect, secure, and monitor services across multiple accounts and VPCs. VPC Lattice simplifies connectivity between your services by eliminating the need to manage load balancers, proxies, or complex networking configurations.

With VPC Lattice, we have seen customers simplify service-to-service communication while enabling advanced authentication, authorization, and monitoring capabilities. This project explores VPC Lattice's capabilities, configuration approaches, and deployment patterns, helping you build and optimize service mesh architectures.

### Service Networks

A [service network](https://docs.aws.amazon.com/vpc-lattice/latest/ug/service-networks.html) is the core construct in VPC Lattice that enables connectivity between services and clients. It acts as a logical boundary for a collection of services that can communicate with each other. Key characteristics of service networks include:

* They can be [shared across AWS accounts](https://docs.aws.amazon.com/vpc-lattice/latest/ug/sharing.html) using AWS Resource Access Manager (RAM).
* They support fine-grained access control through [auth policies](https://docs.aws.amazon.com/vpc-lattice/latest/ug/auth-policies.html).
* They provide [centralized monitoring](https://docs.aws.amazon.com/vpc-lattice/latest/ug/service-network-monitoring.html) and observability for all associated services.

### Services

A VPC Lattice [service](https://docs.aws.amazon.com/vpc-lattice/latest/ug/services.html) represents an application or microservice that you want to make available to clients within your service network. Services are identified by a unique DNS name and can be backed by various compute resources such as EC2 instances, Auto-scaling groups, Lambda functions, or any IP-based target. Alternatively, you can define a [custom domain name](https://docs.aws.amazon.com/vpc-lattice/latest/ug/service-custom-domain-name.html) in your services. Services in VPC Lattice provide:

* Built-in load balancing capabilities.
* Health checks for targets.
* Support for multiple listener protocols (HTTP, HTTPS, gRPC, TLS pass-through)
* Path-based routing to different target groups.
* TLS termination and [certificate management](https://docs.aws.amazon.com/vpc-lattice/latest/ug/service-byoc.html).

### VPC resources

For applications that require a TCP connectivity - both listerner and target - VPC Lattice enables the consumption of [VPC resources](https://docs.aws.amazon.com/vpc-lattice/latest/ug/vpc-resources.html) from a service network. A VPC resource can be an AWS-native resource such as an [Amazon RDS](https://aws.amazon.com/rds/) database, a domain name (publicly resolvable), or an IP address. The resource can be in your VPC or on-premises network and does not need to be load-balanced. VPC resources can be associated to a service network (similar to a VPC Lattice service) and you can share them using AWS RAM to specificy the principals who can access the resource.

### Associations and endpoints

Communication is possible in VPC Lattice by connecting both consumers and producers (VPC Lattice services or VPC resources) to a service network.

VPC Lattice services can be exposed via VPC Lattice by creating a [service association](https://docs.aws.amazon.com/vpc-lattice/latest/ug/service-associations.html) to service networks. When you associate a service with a service network, the service becomes discoverable and accessible to clients within VPCs associated with that service network. 

Consumers located in a VPC can consume services by creating a [VPC association](https://docs.aws.amazon.com/vpc-lattice/latest/ug/service-network-associations.html#service-network-vpc-associations) to a service network. When you associate a VPC with a service network, VPC Lattice creates the necessary networking infrastructure to enable communication. However, this VPC association will only enable connectivity via VPC Lattice to consumers in that VPC. For resources in on-premises or cross-Region environments, you should use a [service network endpoint](https://docs.aws.amazon.com/vpc-lattice/latest/ug/service-network-associations.html#service-network-vpc-endpoint-associations) to allow these resources to connect to the service network using a routable network (hybrid or cross-Region) from external environments.

### Listeners and targets

VPC Lattice services use listeners and target groups to route traffic from clients to backend targets. [Listeners](https://docs.aws.amazon.com/vpc-lattice/latest/ug/listeners.html) define how your service accepts incoming requests. Protocols supported are **HTTP**, **HTTPS**, and **TLS**.

* For HTTPS, VPC Lattice will provision and manage a TLS certificate associated with the VPC Lattice generated FQDN. For custom domain names, you can use [AWS Certificate Manager](https://aws.amazon.com/certificate-manager/) (ACM) to associate a certificate.
* VPC Lattice supports TLS on HTTP/1.1 and HTTP/2.
* Listener and traget don't require to have a matching protocol.
* TLS listeners ensure that your application is the one decrypting the traffic (TLS passthrough).

[Target groups](https://docs.aws.amazon.com/vpc-lattice/latest/ug/target-groups.html) define where traffic is routed after it's received by a listener. Protocols supported are **HTTP**, **HTTPS**, and **TCP** (only for TLS listeners). The following targets are supported:

* **EC2 instances** identified by instance ID. When associating an Autoscaling group to a VPC Lattice service, this is the target type used.
* **IP addresses** within a VPC CIDR range. You can't register VPC endpoints or publicly routable IP addresses.
    * You can register ECS tasks with a VPC Lattice target group, using an IP target type.
    * You can register EKS pods as a target, using the [AWS Gateway API Controller](https://www.gateway-api-controller.eks.aws.dev/latest/), which gets the IP addresses from the Kubernetes service. 
* **Lambda functions**.
* **Application Load Balancers**.

### Security and observability

[Auth policies](https://docs.aws.amazon.com/vpc-lattice/latest/ug/auth-policies.html) in VPC Lattice control who can access services within a service network. These policies can be applied at both the service network and individual service levels, providing granular access control. Check the VPC Lattice documentation for more information about the [format](https://docs.aws.amazon.com/vpc-lattice/latest/ug/auth-policies.html#auth-policies-resource-format) and [condition keys](https://docs.aws.amazon.com/vpc-lattice/latest/ug/auth-policies.html#auth-policies-condition-keys) you can use when defining policies.

For observability, VPC Lattice provides comprehensive [access logging](https://docs.aws.amazon.com/vpc-lattice/latest/ug/monitoring-access-logs.html) capabilities to help you monitor and analyze traffic patterns, troubleshoot issues, and meet compliance requirements. Logs can be enabled at the service network and service level, providing the following information: 

* Request metadata (timestamp, client IP, request path, HTTP method)
* Response information (status code, processing time)
* Authentication details.
* Request and response headers.

Logs can be delivered to [Amazon S3](https://aws.amazon.com/pm/serv-s3/), [Amazon CloudWatch Logs](https://docs.aws.amazon.com/AmazonCloudWatch/latest/logs/WhatIsCloudWatchLogs.html), or [Amazon Data Firehose](https://aws.amazon.com/firehose/).

## FAQ

Nothing for now! We will update from your feedback.

## Authors

* Pablo Sánchez Carmona, Sr. Network Specialist Solutions Architect, AWS
* Cristóbal López, Solutions Architect, AWS

## Contributing

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

## License

This library is licensed under the MIT-0 License. See the LICENSE file.
