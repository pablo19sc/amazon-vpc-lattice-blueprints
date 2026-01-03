/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- patterns/2-multi_account/2-distributed/terraform/service-account/variables.tf ---

variable "identifier" {
  type        = string
  description = "Project identifier."

  default = "distributed-share"
}

variable "aws_region" {
  type        = string
  description = "AWS Region."

  default = "eu-west-1"
}