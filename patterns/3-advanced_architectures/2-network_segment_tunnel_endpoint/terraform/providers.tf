/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- patterns/3-advanced_architectures/2-network_segment_tunnel_endpoint/terraform/providers.tf ---

terraform {
  required_version = ">= 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.50.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 1.103.0"
    }
  }
}

# AWS provider definition
provider "aws" {
  region = var.aws_region
}

# AWSCC provider definition
provider "awscc" {
  region = var.aws_region
}
