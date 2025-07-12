/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- patterns/1-simple_architectures/1-ec2_instance/terraform/outputs.tf ---

output "vpclattice_service_domain_name" {
  description = "VPC Lattice service domain name."
  value       = module.service.services.service.attributes.dns_entry[0].domain_name
}