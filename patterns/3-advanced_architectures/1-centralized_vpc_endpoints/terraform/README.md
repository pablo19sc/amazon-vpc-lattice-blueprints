<!-- BEGIN_TF_DOCS -->
# Amazon VPC Lattice - Centralized VPC Endpoints (Terraform)

Terraform implementation of the Centralized VPC Endpoints pattern. For the architecture, what gets deployed, and the connectivity testing steps, see the [pattern README](../README.md).

| File | Resources |
|------|-----------|
| `centralized_endpoints.tf` | Endpoints VPC, interface VPC endpoints, resource gateway, the resource configurations of both consumption models, and their access logging |
| `consumer_group.tf` | Service network (and its access logging), group resource association, and consumer VPC of the group consumption model |
| `consumer_single.tf` | Service network (and its access logging), single resource associations, and consumer VPC of the single consumption model |
| `main.tf` | Common items: EC2 AMI and IAM role |

## Prerequisites

- **AWS Account**: With appropriate IAM permissions
- **Terraform**: >= 1.3.0 installed
- **AWS CLI**: Configured with credentials (optional, for verification)
- **Permissions required**:
  - VPC Lattice: Service networks, resource gateways, resource configurations
  - EC2: VPC, subnets, instances, security groups, VPC endpoints
  - IAM: Create roles and policies

## Deployment

```bash
# Clone the repository
git clone https://github.com/aws-samples/amazon-vpc-lattice-blueprints.git

# Navigate to the Terraform directory
cd patterns/3-advanced_architectures/1-centralized_vpc_endpoints/terraform

# (Optional) Configure variables
# Create terraform.tfvars to customize:
# - identifier
# - aws_region
# - vpc_endpoints (list of AWS services)

# Initialize Terraform
terraform init

# (Optional) Review the planned changes
terraform plan

# Deploy the resources
terraform apply
```

> **Note**: The VPC endpoints and the resource gateway are deployed in all the Availability Zones configured for the endpoints VPC, while each consumer VPC runs a single EC2 instance (one per consumption model). Keep this in mind when testing this environment from a cost perspective - for production environments, we recommend the use of at least 2 AZs for high-availability.

## Cleanup

```bash
# Destroy all resources
terraform destroy
```

> **Note**: The access-logging CloudWatch Logs log groups (`/aws/vpclattice/<identifier>/*`) are managed by this pattern, so `terraform destroy` removes them — no manual cleanup is required.

## Observability: Access logging

This pattern enables VPC Lattice **access logging** by default, with one CloudWatch Logs log group per item (7-day retention, `<identifier>` is the `identifier` variable). The same connection is logged from two views: the service network owner's (which consumer VPC reached what through that service network) and the endpoints owner's (who reached the resource configurations, through any service network).

| Log group | Source |
|-----------|--------|
| `/aws/vpclattice/<identifier>/service-network-group` | Group service network (`RESOURCE` log type) |
| `/aws/vpclattice/<identifier>/service-network-single` | Single service network (`RESOURCE` log type) |
| `/aws/vpclattice/<identifier>/resource-config-group` | Group resource configuration |
| `/aws/vpclattice/<identifier>/resource-config-single` | All single resource configurations |

- **Where to find the logs**: CloudWatch Logs console → **Log groups**, or from the CLI:

  ```bash
  aws logs tail /aws/vpclattice/<identifier>/service-network-group --follow
  ```

- **How to interpret them**: each entry records one connection (source VPC, resource configuration, resource gateway and resource IP/port) — Useful for observability of traffic to the centralized endpoints.

> **Cost note**: Access logging uses CloudWatch Logs vended-logs pricing (ingestion + storage). For this demo it is a small ongoing cost while the pattern is deployed.

## Testing

After deployment, follow the [Testing Connectivity](../README.md#testing-connectivity) steps in the pattern README to connect to each consumer instance (`instance_ids` output, keyed `group` and `single`) via Systems Manager and compare how both consumption models resolve AWS service endpoints.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.50.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 1.67.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.50.0 |
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | >= 1.67.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_consumer_vpc_group"></a> [consumer\_vpc\_group](#module\_consumer\_vpc\_group) | aws-ia/vpc/aws | = 4.9.0 |
| <a name="module_consumer_vpc_single"></a> [consumer\_vpc\_single](#module\_consumer\_vpc\_single) | aws-ia/vpc/aws | = 4.7.3 |
| <a name="module_endpoints_vpc"></a> [endpoints\_vpc](#module\_endpoints\_vpc) | aws-ia/vpc/aws | = 4.9.0 |
| <a name="module_vpc_endpoints"></a> [vpc\_endpoints](#module\_vpc\_endpoints) | ../../../tf_modules/vpc_endpoints | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.resource_configuration_access_logs_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.resource_configuration_access_logs_single](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.service_network_access_logs_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.service_network_access_logs_single](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_instance_profile.ec2_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy_attachment.ssm_iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.role_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_instance.ec2_instance_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.ec2_instance_single](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.instance_sg_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.instance_sg_single](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.resource_gateway_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.vpc_lattice_sg_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.vpc_lattice_sg_single](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.allowing_egress_any_ipv4_consumer_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.allowing_egress_any_ipv4_consumer_single](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.allowing_egress_any_ipv6_consumer_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.allowing_egress_any_ipv6_consumer_single](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.allowing_egress_any_tcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.allowing_ingress_ec2instance_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.allowing_ingress_ec2instance_single](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpclattice_access_log_subscription.resource_configuration_access_logs_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_access_log_subscription) | resource |
| [aws_vpclattice_access_log_subscription.resource_configuration_access_logs_single](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_access_log_subscription) | resource |
| [aws_vpclattice_access_log_subscription.service_network_access_logs_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_access_log_subscription) | resource |
| [aws_vpclattice_access_log_subscription.service_network_access_logs_single](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_access_log_subscription) | resource |
| [aws_vpclattice_resource_configuration.resource_configuration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_resource_configuration) | resource |
| [aws_vpclattice_resource_configuration.resource_configuration_single](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_resource_configuration) | resource |
| [aws_vpclattice_resource_gateway.resource_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_resource_gateway) | resource |
| [aws_vpclattice_service_network.service_network_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_service_network) | resource |
| [aws_vpclattice_service_network.service_network_single](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_service_network) | resource |
| [aws_vpclattice_service_network_resource_association.resource_association_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_service_network_resource_association) | resource |
| [aws_vpclattice_service_network_resource_association.resource_association_single](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_service_network_resource_association) | resource |
| [aws_vpclattice_service_network_vpc_association.service_network_vpc_association_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_service_network_vpc_association) | resource |
| [aws_vpclattice_service_network_vpc_association.service_network_vpc_association_single](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_service_network_vpc_association) | resource |
| [awscc_vpclattice_resource_configuration.resource_configuration_group_vpcendpoints](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/vpclattice_resource_configuration) | resource |
| [aws_ami.amazon_linux](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region to build the pattern. | `string` | `"eu-west-1"` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Pattern identifier. | `string` | `"endpoints"` | no |
| <a name="input_vpc_endpoints"></a> [vpc\_endpoints](#input\_vpc\_endpoints) | VPC endpoints (AWS services) to centralized using VPC resources. | `list(string)` | <pre>[<br/>  "ssm",<br/>  "ssmmessages",<br/>  "ec2messages",<br/>  "sts"<br/>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_ids"></a> [instance\_ids](#output\_instance\_ids) | EC2 Instance IDs, per consumption model (group / single). |
<!-- END_TF_DOCS -->
