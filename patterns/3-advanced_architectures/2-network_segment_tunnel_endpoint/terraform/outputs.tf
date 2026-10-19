/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- patterns/3-advanced_architectures/2-network_segment_tunnel_endpoint/terraform/outputs.tf ---

# Consumer EC2 instance IDs.
output "consumer_instance_ids" {
  description = "Consumer EC2 instance IDs (use with EC2 Instance Connect)."
  value       = aws_instance.consumer_instance[*].id
}

# Private IPs of the hosts inside the shared network segment.
output "segment_host_ips" {
  description = "Private IPv4 addresses of the web hosts inside the shared network segment."
  value       = aws_instance.segment_host[*].private_ip
}
