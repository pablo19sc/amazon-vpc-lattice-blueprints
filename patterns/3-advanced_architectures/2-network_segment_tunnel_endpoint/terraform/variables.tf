/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- patterns/3-advanced_architectures/2-network_segment_tunnel_endpoint/terraform/variables.tf ---

variable "identifier" {
  type        = string
  description = "Project identifier."

  default = "network-segment"
}

variable "aws_region" {
  type        = string
  description = "AWS Region to build the pattern."

  default = "eu-west-1"
}

variable "consumer_vpc" {
  type        = any
  description = "Consumer VPC."

  default = {
    cidr_block               = "10.0.0.0/16"
    number_azs               = 2
    workload_subnet_netmask  = 24
    endpoints_subnet_netmask = 24
    instance_type            = "t3.micro"
  }
}

variable "provider_vpc" {
  type        = any
  description = "Provider VPC."

  default = {
    cidr_block                   = "10.1.0.0/16"
    number_azs                   = 2
    resourcegateway_subnet_cidrs = ["10.1.0.0/24", "10.1.1.0/24"]
    workload_subnet_cidrs        = ["10.1.2.0/24", "10.1.3.0/24"]
    instance_type                = "t3.micro"
  }
}

variable "segment_port" {
  type        = number
  description = "TCP port the segment hosts listen on, and the only port the resource configuration shares."

  default = 80
}
