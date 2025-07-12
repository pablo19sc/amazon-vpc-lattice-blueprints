<!-- BEGIN_TF_DOCS -->
# Amazon VPC Lattice - EC2 Instance & IP target type

![EC2 Instance & IP target](../../../../images/pattern1\_architecture2.png)

## Prerequisites
- An AWS account with an IAM user with the appropriate permissions
- Terraform installed

## Code Principles:
- Writing DRY (Do No Repeat Yourself) code using a modular design pattern

## Usage
- Clone the repository.
- (Optional) Edit the variables under variables.tf file in the project root directory - if you want to test with different parameters.
- Deploy the resources using `terraform apply`.
- Remember to clean up resoures once you are done by using `terraform destroy`.

**Note** EC2 instances will be deployed in all the Availability Zones configured for each VPC. Keep this in mind when testing this environment from a cost perspective - for production environments, we recommend the use of at least 2 AZs for high-availability.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.67.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.67.0 |

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
| <a name="output_vpclattice_service_domain_name"></a> [vpclattice\_service\_domain\_name](#output\_vpclattice\_service\_domain\_name) | VPC Lattice service domain name. |
<!-- END_TF_DOCS -->