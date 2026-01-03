/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- patterns/2-multi_account/2-distributed/terraform/service-account/outputs.tf ---

output "service_domain_name" {
  description = "VPC Lattice services domain name."
  value       = { for k, v in module.vpc_lattice_service.services : k => v.attributes.dns_entry[0].domain_name }
}