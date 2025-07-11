/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- patterns/tf_modules/consumer_instance/outputs.tf ---

output "consumer_sg" {
  description = "Consumer VPC security group ID."
  value       = aws_security_group.instance_sg.id
}