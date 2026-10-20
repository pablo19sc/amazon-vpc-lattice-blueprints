/* Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 SPDX-License-Identifier: MIT-0 */

# --- patterns/3-advanced_architectures/1-centralized_vpc_endpoints/terraform/main.tf ---

# Common items used by both consumption models. The rest of the pattern is split as if each file were a separate account:
# - centralized_endpoints.tf: endpoints VPC, VPC endpoints, resource gateway and resource configurations
# - consumer_group.tf: consumption through the group resource configuration
# - consumer_single.tf: consumption through single resource configurations

# ---------- EC2 INSTANCES (AMI + IAM ROLE) ----------
# Data resource to determine the latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# IAM instance profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-instance-profile-${var.identifier}"
  role = aws_iam_role.role_ec2.id
}

# IAM role
resource "aws_iam_role" "role_ec2" {
  name               = "ec2-ssm-role-${var.identifier}"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.policy_document.json
}

data "aws_iam_policy_document" "policy_document" {
  statement {
    sid     = "1"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

  }
}

# Policies Attachment to Role
resource "aws_iam_policy_attachment" "ssm_iam_role_policy_attachment" {
  name       = "ssm-iam-role-policy-attachment-${var.identifier}"
  roles      = [aws_iam_role.role_ec2.id]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
