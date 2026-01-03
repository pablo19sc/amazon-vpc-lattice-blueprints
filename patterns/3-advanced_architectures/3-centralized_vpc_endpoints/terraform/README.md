<!-- BEGIN_TF_DOCS -->
# Amazon VPC Lattice - Centralized VPC Endpoints (Terraform)

![Centralized VPC Endpoints Architecture](../../../../images/centralized.png)

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
cd patterns/3-advanced_architectures/3-centralized_vpc_endpoints/terraform

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

> **Note**: EC2 instances and VPC endpoints will be deployed in all the Availability Zones configured for each VPC. Keep this in mind when testing this environment from a cost perspective - for production environments, we recommend the use of at least 2 AZs for high-availability.

## Cleanup

```bash
# Destroy all resources
terraform destroy
```

## Next Steps

After successfully deploying this pattern:

1. **Test connectivity**: Verify EC2 instances can access AWS services through centralized endpoints.
2. **Add more endpoints**: Modify the CloudFormation templates to include additional AWS services.
3. **Scale consumers**: Deploy additional consumer VPCs to share the centralized endpoints.
4. **Production hardening**: Add monitoring, logging, and alerting for the centralized endpoints.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 1.65.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.27.0 |
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | 1.67.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_consumer_vpc"></a> [consumer\_vpc](#module\_consumer\_vpc) | aws-ia/vpc/aws | 4.7.3 |
| <a name="module_endpoints_vpc"></a> [endpoints\_vpc](#module\_endpoints\_vpc) | aws-ia/vpc/aws | 4.7.3 |
| <a name="module_vpc_endpoints"></a> [vpc\_endpoints](#module\_vpc\_endpoints) | ../../../tf_modules/vpc_endpoints | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_instance_profile.ec2_instance_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy_attachment.ssm_iam_role_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy_attachment) | resource |
| [aws_iam_role.role_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_instance.ec2_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.instance_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.resource_gateway_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.vpc_lattice_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.allowing_egress_any_ipv4_consumer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.allowing_egress_any_ipv6_consumer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.allowing_egress_any_tcp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.allowing_ingress_ec2instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpclattice_resource_gateway.resource_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_resource_gateway) | resource |
| [aws_vpclattice_service_network.service_network](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpclattice_service_network) | resource |
| [awscc_vpclattice_resource_configuration.resource_configuration](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/vpclattice_resource_configuration) | resource |
| [awscc_vpclattice_service_network_resource_association.resource_association](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/vpclattice_service_network_resource_association) | resource |
| [awscc_vpclattice_service_network_vpc_association.service_network_vpc_association](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/vpclattice_service_network_vpc_association) | resource |
| [aws_ami.amazon_linux](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.policy_document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region to build the pattern. | `string` | `"eu-west-1"` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Pattern identifier. | `string` | `"centralized-endpoints"` | no |
| <a name="input_vpc_endpoints"></a> [vpc\_endpoints](#input\_vpc\_endpoints) | VPC endpoints (AWS services) to centralized using VPC resources. | `list(string)` | <pre>[<br/>  "ssm",<br/>  "ssmmessages",<br/>  "ec2messages",<br/>  "sts"<br/>]</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_ids"></a> [instance\_ids](#output\_instance\_ids) | EC2 Instance IDs. |
<!-- END_TF_DOCS -->