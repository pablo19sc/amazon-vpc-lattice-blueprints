<!-- BEGIN_TF_DOCS -->
# Amazon VPC Lattice - Auto Scaling Group Target (Terraform)

![Auto Scaling Group target](../../../images/pattern1\_architecture2.png)

## Prerequisites

- **AWS Account**: With appropriate IAM permissions
- **Terraform**: >= 1.3.0 installed
- **AWS CLI**: Configured with credentials (optional, for verification)
- **Permissions required**:
  - VPC Lattice: Service networks, services, target groups
  - EC2: VPC, subnets, instances, security groups, Auto Scaling groups
  - IAM: Create roles and policies

## Deployment

```bash
# Clone the repository
git clone https://github.com/aws-samples/amazon-vpc-lattice-blueprints.git

# Navigate to the Terraform directory
cd patterns/1-simple_architectures/2-auto_scaling_group/terraform

# Initialize Terraform
terraform init

# (Optional) Review the planned changes
terraform plan

# Deploy the resources
terraform apply
```

> **Note**: The Auto Scaling group will deploy EC2 instances in all configured Availability Zones. Keep this in mind when testing this environment from a cost perspective - for production environments, we recommend the use of at least 2 AZs for high-availability.

## Cleanup

```bash
# Destroy all resources
terraform destroy
```

## Testing

After deployment, follow the testing steps in the [Pattern 2 - Auto Scaling Group Testing Connectivity section](../README.md#testing-connectivity-1) to verify connectivity between consumer instances and the Auto Scaling group through VPC Lattice.

## Next Steps

After successfully deploying this pattern:

1. **Test connectivity**: Follow the testing guide to verify the service works correctly
2. **Explore other targets**: Try [EC2 Instance](../../1-ec2\_instance/), [Lambda](../../3-lambda\_function/), or [ECS](../../4-ecs/) patterns
3. **Multi-Account**: Move to [Multi-Account patterns](../../../2-multi\_account/) for cross-account deployments
4. **Advanced architectures**: Explore [Advanced patterns](../../../3-advanced\_architectures/) for more complex scenarios

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.27.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_consumer_instances"></a> [consumer\_instances](#module\_consumer\_instances) | ../../../tf_modules/consumer_instance | n/a |
| <a name="module_consumer_vpc"></a> [consumer\_vpc](#module\_consumer\_vpc) | aws-ia/vpc/aws | = 4.5.0 |
| <a name="module_provider_vpc"></a> [provider\_vpc](#module\_provider\_vpc) | aws-ia/vpc/aws | = 4.5.0 |
| <a name="module_service"></a> [service](#module\_service) | aws-ia/amazon-vpc-lattice-module/aws | 1.1.0 |
| <a name="module_service_network"></a> [service\_network](#module\_service\_network) | aws-ia/amazon-vpc-lattice-module/aws | 1.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_autoscaling_group.web_asg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_autoscaling_traffic_source_attachment.asg_target_vpclattice](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_traffic_source_attachment) | resource |
| [aws_launch_template.launch_template_webinstance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) | resource |
| [aws_security_group.provider_instance_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.vpclattice_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc_security_group_egress_rule.provider_allowing_egress_any](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.provider_allowing_egress_any_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.allowing_ingress_http_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.allowing_ingress_http_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.allowing_ingress_https_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.allowing_ingress_https_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.allowing_ingress_instances_https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_ami.amazon_linux](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ec2_managed_prefix_list.vpclattice_pl_ipv4](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_managed_prefix_list) | data source |
| [aws_ec2_managed_prefix_list.vpclattice_pl_ipv6](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_managed_prefix_list) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS Region to use in the example. | `string` | `"eu-west-1"` | no |
| <a name="input_identifier"></a> [identifier](#input\_identifier) | Project identifier. | `string` | `"asg-target"` | no |
| <a name="input_vpc"></a> [vpc](#input\_vpc) | Information about the VPCs. | `any` | <pre>{<br/>  "cidr_block": "10.0.0.0/16",<br/>  "endpoints_subnet_netmask": 24,<br/>  "instance_type": "t2.micro",<br/>  "number_azs": 2,<br/>  "private_subnet_netmask": 24<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_consumer_instance_ids"></a> [consumer\_instance\_ids](#output\_consumer\_instance\_ids) | Consumer EC2 Instance IDs |
| <a name="output_vpclattice_service_domain_name"></a> [vpclattice\_service\_domain\_name](#output\_vpclattice\_service\_domain\_name) | VPC Lattice service domain name. |
<!-- END_TF_DOCS -->