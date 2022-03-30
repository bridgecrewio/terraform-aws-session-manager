# Terraform AWS Session Manager

A Terraform module to setup [AWS Systems Manager Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html).

This module creates the a SSM document to support encrypted session manager communication and logs. It also creates a KMS key, S3 bucket, and CloudWatch Log group to store logs. In addition, for EC2 instances without a public IP address it can create VPC endpoints to enable private session manager communication. However, the VPC endpoint creation can also be facilitated by other modules such as [this](https://github.com/terraform-aws-modules/terraform-aws-vpc). Be aware of the [AWS PrivateLink pricing](https://aws.amazon.com/privatelink/pricing/) before deployment.

## Usage

Update version to the latest release here: <https://github.com/bridgecrewio/terraform-aws-session-manager/releases>

Instances with Public IPs do not need VPC endpoints

```terraform
module "ssm" {
  source                    = "bridgecrewio/session-manager/aws"
  version                   = "0.2.0"
  bucket_name               = "my-session-logs"
  access_log_bucket_name    = "my-session-access-logs"
  enable_log_to_s3          = true
  enable_log_to_cloudwatch  = true
}
```

Private instances with VPC endpoints for S3 and CloudWatch logging

```terraform
module "ssm" {
  source                    = "bridgecrewio/session-manager/aws"
  version                   = "0.2.0"
  bucket_name               = "my-session-logs"
  access_log_bucket_name    = "my-session-access-logs"
  enable_log_to_s3          = true
  enable_log_to_cloudwatch  = true
  vpc_endpoints_enabled     = true
  vpc_id                    = "vpc-0dc9ef19c0c23aeaa"
  tags = {
    Function = "ssm"
  }
}
```

This module does not create any IAM policies for access to session manager. To do that, look at example policies in the [AWS Documentation](https://docs.aws.amazon.com/systems-manager/latest/userguide/getting-started-restrict-access-quickstart.html)

## Notes

In case `Session Manager` has already been accessed using AWS console, `SSM-SessionManagerRunShell` document - which is otherwise managed by this module - may need to be deleted prior to running this module. The following error may occur if the document has not been deleted upfront:

`Error: Error creating SSM document: DocumentAlreadyExists: Document with same name SSM-SessionManagerRunShell already exists`

To delete the document, issue:

`aws ssm delete-document --name SSM-SessionManagerRunShell`

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| aws | >= 1.36 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 1.36 |

## Inputs

Below is a list of this modules input values:

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| bucket\_name | Name of S3 bucket to store session logs | `string` | `ssm-session-logs-<account-id>-<region-id>` | no |
| bucket\_key\_prefix | Name of S3 sub-folder (prefix) | `string` | | no |
| log\_archive\_days | Number of days to wait before archiving to Glacier | `number` | `30` | no |
| log\_expire\_days | Number of days to wait before deleting session logs | `number` | `365` | no |
| access\_log\_bucket\_name | Name of the S3 bucket to store bucket access logs | `string` | `ssm-session-access-logs-<account-id>-<region-id>` | no |
| access\_log\_expire\_days | Number of days to wait before deleting access logs | `number` | `30` | no |
| kms\_key\_deletion\_window | Number of days to wait for scheduled KMS Key deletion [7-30] | `number` | `7` | no |
| kms\_key\_alias | Alias of the KMS key. Must start with alias/ followed by a name | `string` | `alias/ssm-key` | no |
| cloudwatch\_logs\_retention | Number of days to retain Session Logs in CloudWatch | `number` | `30` | no |
| cloudwatch\_log\_group\_name | Name of the CloudWatch Log Group for storing SSM Session Logs | `string` | `/ssm/session-logs` | no |
| idle\_session\_timeout| Number of minutes a user can be inactive before a session ends [1-60] | `number` | `20` | no |
| run\_as\_default\_user | OS default user name, if IAM user/role 'SSMSessionRunAs' tag is undefined | `string` | `ssm-user` | no |
| shell\_profile\_windows | Environment variables, shell preferences, or commands to run when session starts | `string` | | no |
| shell\_profile\_linux | Environment variables, shell preferences, or commands to run when session starts | `string` | | no |
| enable\_log\_to\_s3 | Enable Session Manager to Log to S3 | `bool` | `true` | no |
| enable\_log\_to\_cloudwatch | Enable Session Manager to Log to CloudWatch Logs | `bool` | `true` | no |
| enable\_run\_as\_user | Enable Run As support for Linux instances | `bool` | `false` | no |
| vpc\_endpoints\_enabled | Create VPC Endpoints | `bool` | `false` | no |
| vpc\_id | VPC ID to deploy endpoints to | `string` | `null` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Example Value | Description |
|------|----------------|-------------|
| session\_logs\_bucket\_name | my-session-logs | S3 bucket for session logs |
| access\_log\_bucket\_name | my-session-access-logs | S3 bucket for S3 access logs |
| cloudwatch\_log\_group\_arn | arn:aws:logs:us-west-2:123456789012:log-group:/ssm/session-logs:\* | CloudWatch Log group for session logs |
| kms\_key\_arn | arn:aws:kms:us-west-2:123456789012:key/2320fbba-d4e5-420d-82d3-1a4d6b8605e8 | KMS Key Arn for Encrypting logs and session |
| iam\_policy\_arn | arn:aws:iam::123456789012:policy/ssm\_s3\_cwl\_kms\_access\_us-east-1 | IAM Policy for EC2 instances |
| iam\_role\_arn | arn:aws:iam::123456789012:role/ssm\_role\_us-east-1 | IAM Role for EC2 instances |
| iam\_profile\_name | ssm\_profile\_us-east-1 | EC2 instance profile for SSM |
| ssm\_security\_group | ["sg-05e4f4cf12db5a191"] | Security Group used to access VPC Endpoints |
| vpc\_endpoint\_ssm | ["vpce-0cefc23e81d365733"] | VPC Endpoint for SSM |
| vpc\_endpoint\_ec2messages | ["vpce-0f507468fb9b06b8b"] | VPC Endpoint for EC2 Messages |
| vpc\_endpoint\_ssmmessages | ["vpce-0fe2cb670d40ec053"] | VPC Endpoint for SSM Messages |
| vpc\_endpoint\_s3 | ["vpce-0a8ebde94fa301a4a"] | VPC Endpoint for S3 |
| vpc\_endpoint\_logs | ["vpce-08c90d8df9ef37f90"] | VPC Endpoint for CloudWatch Logs |
| vpc\_endpoint\_kms | ["vpce-07ddc11beac1d4a3f"] | VPC Endpoint for KMS |

## SSM Usage Example

* Launch an instance using the ssm\_profile created by Terraform
* Install the session-manager-plugin and start a session

```bash
cd /tmp
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac/sessionmanager-bundle.zip" -o "sessionmanager-bundle.zip"
unzip sessionmanager-bundle.zip
sudo ./sessionmanager-bundle/install -i /usr/local/sessionmanagerplugin -b /usr/local/bin/session-manager-plugin

# Verify
session-manager-plugin

cd -

# Start an SSM session - Note the instance must have a public IP if you have not created VPC endpoints
aws ssm start-session --target <EC2 Instance ID>
```

* Review session logs in your CloudWatch logs group
* Review session logs in your S3 bucket

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=0.14.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.session_manager_log_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_iam_instance_profile.ssm_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_policy.ssm_s3_cwl_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ssm_s3_cwl_kms_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.ssm_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.SSM-role-policy-attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.SSM-s3-cwl-kms-policy-attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.SSM-s3-cwl-policy-attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.ssmkey](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.ssmkey](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.access_log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.session_logs_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.access_log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_acl.session_logs_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_lifecycle_configuration.access_log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_lifecycle_configuration.session_logs_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_lifecycle_configuration) | resource |
| [aws_s3_bucket_logging.session_logs_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_public_access_block.access_log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_public_access_block.session_logs_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.access_log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.session_logs_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.access_log_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.session_logs_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_security_group.ssm_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ssm_document.session_manager_prefs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_document) | resource |
| [aws_vpc_endpoint.ec2messages](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint.ssmmessages](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_vpc_endpoint_route_table_association.private_s3_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_route_table_association) | resource |
| [aws_vpc_endpoint_route_table_association.private_s3_subnet_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint_route_table_association) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy.AmazonSSMManagedInstanceCore](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy_document.kms_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms_key_default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ssm_s3_cwl_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ssm_s3_cwl_kms_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route_table.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route_table) | data source |
| [aws_subnet_ids.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet_ids) | data source |
| [aws_vpc.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_log_bucket_name"></a> [access\_log\_bucket\_name](#input\_access\_log\_bucket\_name) | Name prefix of S3 bucket to store access logs from session logs bucket | `string` | `""` | no |
| <a name="input_access_log_expire_days"></a> [access\_log\_expire\_days](#input\_access\_log\_expire\_days) | Number of days to wait before deleting access logs | `number` | `30` | no |
| <a name="input_bucket_key_prefix"></a> [bucket\_key\_prefix](#input\_bucket\_key\_prefix) | Name of S3 sub-folder (prefix) | `string` | `""` | no |
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name prefix of S3 bucket to store session logs | `string` | `""` | no |
| <a name="input_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#input\_cloudwatch\_log\_group\_name) | Name of the CloudWatch Log Group for storing SSM Session Logs | `string` | `"/ssm/session-logs"` | no |
| <a name="input_cloudwatch_logs_retention"></a> [cloudwatch\_logs\_retention](#input\_cloudwatch\_logs\_retention) | Number of days to retain Session Logs in CloudWatch | `number` | `30` | no |
| <a name="input_enable_log_to_cloudwatch"></a> [enable\_log\_to\_cloudwatch](#input\_enable\_log\_to\_cloudwatch) | Enable Session Manager to Log to CloudWatch Logs | `bool` | `true` | no |
| <a name="input_enable_log_to_s3"></a> [enable\_log\_to\_s3](#input\_enable\_log\_to\_s3) | Enable Session Manager to Log to S3 | `bool` | `true` | no |
| <a name="input_enable_run_as"></a> [enable\_run\_as](#input\_enable\_run\_as) | Enable Run As support for Linux instances | `bool` | `false` | no |
| <a name="input_idle_session_timeout"></a> [idle\_session\_timeout](#input\_idle\_session\_timeout) | Number of minutes a user can be inactive before a session ends [1-60] | `number` | `20` | no |
| <a name="input_kms_key_alias"></a> [kms\_key\_alias](#input\_kms\_key\_alias) | Alias prefix of the KMS key.  Must start with alias/ followed by a name | `string` | `"alias/ssm-key"` | no |
| <a name="input_kms_key_deletion_window"></a> [kms\_key\_deletion\_window](#input\_kms\_key\_deletion\_window) | Number of days to wait for scheduled KMS Key deletion [7-30] | `number` | `7` | no |
| <a name="input_log_archive_days"></a> [log\_archive\_days](#input\_log\_archive\_days) | Number of days to wait before archiving to Glacier | `number` | `30` | no |
| <a name="input_log_expire_days"></a> [log\_expire\_days](#input\_log\_expire\_days) | Number of days to wait before deleting | `number` | `365` | no |
| <a name="input_run_as_default_user"></a> [run\_as\_default\_user](#input\_run\_as\_default\_user) | OS default user name, if IAM user/role 'SSMSessionRunAs' tag is undefined | `string` | `"ssm-user"` | no |
| <a name="input_shell_profile_linux"></a> [shell\_profile\_linux](#input\_shell\_profile\_linux) | Environment variables, shell preferences, or commands to run when session starts | `string` | `""` | no |
| <a name="input_shell_profile_windows"></a> [shell\_profile\_windows](#input\_shell\_profile\_windows) | Environment variables, shell preferences, or commands to run when session starts | `string` | `""` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet Ids to deploy endpoints into | `set(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_endpoint_private_dns_enabled"></a> [vpc\_endpoint\_private\_dns\_enabled](#input\_vpc\_endpoint\_private\_dns\_enabled) | Enable private dns for endpoints | `bool` | `true` | no |
| <a name="input_vpc_endpoints_enabled"></a> [vpc\_endpoints\_enabled](#input\_vpc\_endpoints\_enabled) | Create VPC Endpoints | `bool` | `false` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID to deploy endpoints into | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_log_bucket_name"></a> [access\_log\_bucket\_name](#output\_access\_log\_bucket\_name) | S3 bucket for S3 access logs |
| <a name="output_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#output\_cloudwatch\_log\_group\_arn) | CloudWatch Log group for session logs |
| <a name="output_document_arn"></a> [document\_arn](#output\_document\_arn) | ARN of the created document. This can be used to create IAM policies that prevent changes to session manager preferences |
| <a name="output_document_name"></a> [document\_name](#output\_document\_name) | Name of the created document |
| <a name="output_iam_policy_arn"></a> [iam\_policy\_arn](#output\_iam\_policy\_arn) | IAM Policy for EC2 instances |
| <a name="output_iam_profile_name"></a> [iam\_profile\_name](#output\_iam\_profile\_name) | EC2 instance profile for SSM |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | EC2 instance profile for SSM |
| <a name="output_kms_key_arn"></a> [kms\_key\_arn](#output\_kms\_key\_arn) | KMS Key Arn for Encrypting logs and session |
| <a name="output_session_logs_bucket_name"></a> [session\_logs\_bucket\_name](#output\_session\_logs\_bucket\_name) | S3 bucket for session logs |
| <a name="output_ssm_security_group"></a> [ssm\_security\_group](#output\_ssm\_security\_group) | Security Group used to access VPC Endpoints |
| <a name="output_vpc_endpoint_ec2messages"></a> [vpc\_endpoint\_ec2messages](#output\_vpc\_endpoint\_ec2messages) | VPC Endpoint for EC2 Messages |
| <a name="output_vpc_endpoint_kms"></a> [vpc\_endpoint\_kms](#output\_vpc\_endpoint\_kms) | VPC Endpoint for KMS |
| <a name="output_vpc_endpoint_logs"></a> [vpc\_endpoint\_logs](#output\_vpc\_endpoint\_logs) | VPC Endpoint for CloudWatch Logs |
| <a name="output_vpc_endpoint_s3"></a> [vpc\_endpoint\_s3](#output\_vpc\_endpoint\_s3) | VPC Endpoint for S3 |
| <a name="output_vpc_endpoint_ssm"></a> [vpc\_endpoint\_ssm](#output\_vpc\_endpoint\_ssm) | VPC Endpoint for SSM |
| <a name="output_vpc_endpoint_ssmmessages"></a> [vpc\_endpoint\_ssmmessages](#output\_vpc\_endpoint\_ssmmessages) | VPC Endpoint for SSM Messages |
<!-- END_TF_DOCS -->