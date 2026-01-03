/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- patterns/1-simple_architectures/1-ec2_instance/terraform/outputs.tf ---

output "service_domain_names" {
  description = "VPC Lattice services' domain names."
  value = {
    service1 = module.service1.services.service1.attributes.dns_entry[0].domain_name
    service2 = var.custom_domain_name
  }
}

output "consumer_instance_ids" {
  description = "Consumer EC2 Instance IDs"
  value       = module.consumer_instances.ec2_instances
}
