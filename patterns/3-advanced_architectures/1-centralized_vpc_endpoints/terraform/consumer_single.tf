/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- patterns/3-advanced_architectures/1-centralized_vpc_endpoints/terraform/consumer_single.tf ---

# ---------- VPC LATTICE SERVICE NETWORK ----------
resource "aws_vpclattice_service_network" "service_network_single" {
  name      = "service-network-single-${var.identifier}"
  auth_type = "NONE"
}

# CloudWatch Logs log group (service network owner view)
resource "aws_cloudwatch_log_group" "service_network_access_logs_single" {
  name              = "/aws/vpclattice/${var.identifier}/service-network-single"
  retention_in_days = 7
}

# Access log subscription (RESOURCE log type - traffic to the associated resource configurations)
resource "aws_vpclattice_access_log_subscription" "service_network_access_logs_single" {
  resource_identifier      = aws_vpclattice_service_network.service_network_single.arn
  destination_arn          = aws_cloudwatch_log_group.service_network_access_logs_single.arn
  service_network_log_type = "RESOURCE"
}

# Resource associations (1 per single resource configuration)
resource "aws_vpclattice_service_network_resource_association" "resource_association_single" {
  for_each = toset(var.vpc_endpoints)

  private_dns_enabled               = true
  resource_configuration_identifier = aws_vpclattice_resource_configuration.resource_configuration_single[each.value].id
  service_network_identifier        = aws_vpclattice_service_network.service_network_single.id

  tags = {
    Name = "resource-association-single-${each.value}-${var.identifier}"
  }
}

# ---------- CONSUMER VPC ----------
# VPC
module "consumer_vpc_single" {
  source  = "aws-ia/vpc/aws"
  version = "= 4.7.3"

  name                                 = "consumer-vpc-single-${var.identifier}"
  az_count                             = 2
  cidr_block                           = "10.0.0.0/16"
  vpc_assign_generated_ipv6_cidr_block = true

  subnets = {
    workload = {
      netmask          = 24
      assign_ipv6_cidr = true
    }
  }
}

# VPC Lattice VPC association
resource "aws_vpclattice_service_network_vpc_association" "service_network_vpc_association_single" {
  vpc_identifier             = module.consumer_vpc_single.vpc_attributes.id
  service_network_identifier = aws_vpclattice_service_network.service_network_single.id
  security_group_ids         = [aws_security_group.vpc_lattice_sg_single.id]

  private_dns_enabled = true
  dns_options {
    private_dns_preference        = "SPECIFIED_DOMAINS_ONLY"
    private_dns_specified_domains = ["*.amazonaws.com"]
  }
}

# EC2 instance
resource "aws_instance" "ec2_instance_single" {
  ami                         = data.aws_ami.amazon_linux.id
  associate_public_ip_address = false
  ipv6_address_count          = 1
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.instance_sg_single.id]
  subnet_id                   = values({ for k, v in module.consumer_vpc_single.private_subnet_attributes_by_az : split("/", k)[1] => v.id if split("/", k)[0] == "workload" })[0]
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.id

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name = "consumer-instance-single-${var.identifier}"
  }
}

# Security Group: EC2 instance
resource "aws_security_group" "instance_sg_single" {
  name        = "consumer-vpc-single-instance-security-group-${var.identifier}"
  description = "EC2 Instance Security Group"
  vpc_id      = module.consumer_vpc_single.vpc_attributes.id
}

resource "aws_vpc_security_group_egress_rule" "allowing_egress_any_ipv4_consumer_single" {
  security_group_id = aws_security_group.instance_sg_single.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "allowing_egress_any_ipv6_consumer_single" {
  security_group_id = aws_security_group.instance_sg_single.id

  ip_protocol = "-1"
  cidr_ipv6   = "::/0"
}

# Security Group: VPC Lattice service network association
resource "aws_security_group" "vpc_lattice_sg_single" {
  name        = "consumer-vpc-single-vpclattice-security-group-${var.identifier}"
  description = "VPC Lattice VPC association Security Group"
  vpc_id      = module.consumer_vpc_single.vpc_attributes.id
}

resource "aws_vpc_security_group_ingress_rule" "allowing_ingress_ec2instance_single" {
  security_group_id = aws_security_group.vpc_lattice_sg_single.id

  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
  referenced_security_group_id = aws_security_group.instance_sg_single.id
}
