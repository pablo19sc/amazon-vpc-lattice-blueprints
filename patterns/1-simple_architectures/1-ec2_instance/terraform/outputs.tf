/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- patterns/1-simple_architectures/1-ec2_instance/terraform/outputs.tf ---

output "service1_domain_name" {
  description = "VPC Lattice service1 domain name."
  value       = module.service1.services.service1.attributes.dns_entry[0].domain_name
}

output "service2_domain_name" {
  description = "VPC Lattice service2 domain name."
  value       = var.custom_domain_name
}