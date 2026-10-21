/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- patterns/3-advanced_architectures/1-centralized_vpc_endpoints/terraform/centralized_endpoints.tf ---

# ---------- CENTRAL VPC ENDPOINTS ----------
module "endpoints_vpc" {
  source  = "aws-ia/vpc/aws"
  version = "= 4.9.0"

  name                                 = "endpoints-vpc-${var.identifier}"
  az_count                             = 2
  cidr_block                           = "10.0.0.0/16"
  vpc_assign_generated_ipv6_cidr_block = true

  subnets = {
    resourcegateway = {
      netmask          = 24
      assign_ipv6_cidr = true
    }
    endpoints = {
      netmask          = 24
      assign_ipv6_cidr = true
    }
  }
}

# VPC endpoints
module "vpc_endpoints" {
  source = "../../../tf_modules/vpc_endpoints"

  identifier                 = var.identifier
  vpc                        = module.endpoints_vpc
  interface_vpc_endpoints    = var.vpc_endpoints
  private_dns                = true
  workload_security_group_id = aws_security_group.resource_gateway_sg.id
}

# ---------- RESOURCE GATEWAY ----------
resource "aws_vpclattice_resource_gateway" "resource_gateway" {
  name                           = "resource-gateway-${var.identifier}"
  vpc_id                         = module.endpoints_vpc.vpc_attributes.id
  subnet_ids                     = values({ for k, v in module.endpoints_vpc.private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "resourcegateway" })
  ip_address_type                = "DUALSTACK"
  resource_config_dns_resolution = "IN_VPC"
  security_group_ids             = [aws_security_group.resource_gateway_sg.id]
}

# Security Group: Resource gateway
resource "aws_security_group" "resource_gateway_sg" {
  name        = "endpoints-vpc-resource-gateway-security-group-${var.identifier}"
  description = "Resource Gateway Security Group"
  vpc_id      = module.endpoints_vpc.vpc_attributes.id
}

resource "aws_vpc_security_group_egress_rule" "allowing_egress_any_tcp" {
  security_group_id = aws_security_group.resource_gateway_sg.id

  ip_protocol = "tcp"
  from_port   = 0
  to_port     = 65535
  cidr_ipv4   = "10.0.0.0/16"
}

# ---------- RESOURCE CONFIGURATIONS: GROUP CONSUMPTION MODEL ----------
# Resource configuration (group) - consumed in consumer_group.tf
resource "awscc_vpclattice_resource_configuration" "resource_configuration_group_vpcendpoints" {
  name                        = "resource-config-group-vpcendpoints"
  resource_gateway_id         = aws_vpclattice_resource_gateway.resource_gateway.id
  port_ranges                 = ["443"]
  protocol_type               = "TCP"
  resource_configuration_type = "GROUP"
  group_domain                = "${var.aws_region}.amazonaws.com"
}

# Resource configuration (1 child per endpoint)
resource "aws_vpclattice_resource_configuration" "resource_configuration" {
  for_each = toset(var.vpc_endpoints)

  name                            = "resource-config-${each.value}-${var.identifier}"
  type                            = "CHILD"
  port_ranges                     = ["443"]
  resource_configuration_group_id = split("/", awscc_vpclattice_resource_configuration.resource_configuration_group_vpcendpoints.id)[1]
  custom_domain_name              = "${each.value}.${var.aws_region}.amazonaws.com"

  resource_configuration_definition {
    dns_resource {
      domain_name     = "${each.value}.${var.aws_region}.amazonaws.com"
      ip_address_type = "IPV4"
    }
  }
}

# CloudWatch Logs log group (group resource configuration - endpoints owner view)
resource "aws_cloudwatch_log_group" "resource_configuration_access_logs_group" {
  name              = "/aws/vpclattice/${var.identifier}/resource-config-group"
  retention_in_days = 7
}

# Access log subscription (group resource configuration)
resource "aws_vpclattice_access_log_subscription" "resource_configuration_access_logs_group" {
  resource_identifier = awscc_vpclattice_resource_configuration.resource_configuration_group_vpcendpoints.arn
  destination_arn     = aws_cloudwatch_log_group.resource_configuration_access_logs_group.arn
}

# ---------- RESOURCE CONFIGURATIONS: SINGLE CONSUMPTION MODEL ----------
# Resource configuration (1 single per endpoint) - consumed in consumer_single.tf
resource "aws_vpclattice_resource_configuration" "resource_configuration_single" {
  for_each = toset(var.vpc_endpoints)

  name                        = "rc-single-${each.value}-${var.identifier}"
  type                        = "SINGLE"
  resource_gateway_identifier = aws_vpclattice_resource_gateway.resource_gateway.id
  port_ranges                 = ["443"]
  protocol                    = "TCP"
  custom_domain_name          = "${each.value}.${var.aws_region}.amazonaws.com"

  resource_configuration_definition {
    dns_resource {
      domain_name     = "${each.value}.${var.aws_region}.amazonaws.com"
      ip_address_type = "IPV4"
    }
  }
}

# CloudWatch Logs log group (single resource configurations - endpoints owner view)
resource "aws_cloudwatch_log_group" "resource_configuration_access_logs_single" {
  name              = "/aws/vpclattice/${var.identifier}/resource-config-single"
  retention_in_days = 7
}

# Access log subscriptions (1 per single resource configuration, same log group)
resource "aws_vpclattice_access_log_subscription" "resource_configuration_access_logs_single" {
  for_each = toset(var.vpc_endpoints)

  resource_identifier = aws_vpclattice_resource_configuration.resource_configuration_single[each.value].arn
  destination_arn     = aws_cloudwatch_log_group.resource_configuration_access_logs_single.arn
}
