---
name: Bug report
about: Create a report to help us improve
title: ''
labels: bug
assignees: pablo19sc

---

## Description

Please provide a clear and concise description of the issue you are encountering, and a reproduction of your configuration. The reproduction MUST be executable either by running `terraform init && terraform apply` or `aws cloudformation deploy` without any further changes.

If your request is for a new feature, please use the `Feature request` template.

- [ ] ✋ I have searched the open/closed issues and my issue is not listed.

## ⚠️ Note

### For Terraform:

1. Remove the local `.terraform` directory (! ONLY if state is stored remotely, which hopefully you are following that best practice!): `rm -rf .terraform/`
2. Re-initialize the project root to pull down modules: `terraform init`
3. Re-attempt your terraform plan or apply and check if the issue still persists

### For CloudFormation:

1. Validate your template syntax: `aws cloudformation validate-template --template-body file://your-template.yaml`
2. Check the CloudFormation stack events for detailed error messages: `aws cloudformation describe-stack-events --stack-name <stack-name>`
3. Re-attempt your deployment and check if the issue still persists

## Versions

- Module version [Required]:
- *For Terraform:*
  - Terraform version: <!-- Execute: terraform -version -->
  - Provider version(s): <!-- Execute: terraform providers -version -->

## Reproduction Code [Required]

<!-- REQUIRED -->

Steps to reproduce the behavior:

<!-- For Terraform: Are you using workspaces? Have you cleared the local cache (see Notice section above)? -->
<!-- For CloudFormation: Which deployment method are you using (CLI, Console, StackSets)? -->
<!-- List steps in order that led up to the issue you encountered -->

## Expected behavior

<!-- A clear and concise description of what you expected to happen -->

## Actual behavior

<!-- A clear and concise description of what actually happened -->
<!-- For CloudFormation: Include relevant stack events or error messages from the console/CLI -->
