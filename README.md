# Terraform AWS Session Manager

A Terraform module to setup [AWS Systems Manager Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html).  

This module creates the a SSM document to support encrypted session manager communication and logs.  It also creates a KMS key, S3 bucket, and CloudWatch Log group to store logs.  In addition, for EC2 instances without a public IP address it can create VPC endpoints to enable private session manager communication.  However, the VPC endpoint creation can also be facilitated by other modules such as [this](https://github.com/terraform-aws-modules/terraform-aws-vpc).  Be aware of the [AWS PrivateLink pricing](https://aws.amazon.com/privatelink/pricing/) before deployment.  

## Usage

Instances with Public IPs do not need VPC endpoints
```
module "ssm" {
  source                    = "bridgecrewio/terraform-aws-session-manager/aws"
  bucket_name               = "my-session-logs"
  access_log_bucket_name    = "my-session-access-logs"
  enable_log_to_s3          = true
  enable_log_to_cloudwatch  = true
}
```

Private instances with VPC endpoints for S3 and CloudWatch logging
```
module "ssm" {
  source                    = "bridgecrewio/terraform-aws-session-manager/aws"
  bucket_name               = "my-session-logs"
  access_log_bucket_name    = "my-session-access-logs"
  vpc_id                    = "vpc-0dc9ef19c0c23aeaa"
  tags                      = {
                                Function = "ssm"
                              }
  enable_log_to_s3          = true
  enable_log_to_cloudwatch  = true
  vpc_endpoints_enabled     = true
}
```

This module does not create any IAM policies for access to session manager.  To do that, look at example policies in the [AWS Documentation](https://docs.aws.amazon.com/systems-manager/latest/userguide/getting-started-restrict-access-quickstart.html)



## Inputs
Below is a list of this modules input values:
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| bucket\_name | Name of S3 bucket to store session logs | `string` | | yes |
| log\_archive\_days | Number of days to wait before archiving to Glacier | `number` | `30` | no |
| log\_expire\_days | Number of days to wait before deleting session logs | `number` | `365` | no |
| access\_log\_bucket\_name | Name of the S3 bucket to store bucket access logs | `string` | | yes | 
| access\_log\_expire\_days | Number of days to wait before deleting access logs | `number` | `30` | no |
| kms\_key\_deletion\_window | Waiting period for scheduled KMS Key deletion.  Can be 7-30 days | `number` | `7` | no |
| kms\_key\_alias | Alias of the KMS key.  Must start with alias/ followed by a name | `string` | `alias/ssm-key` | no | 
| cloudwatch\_logs\_retention | Number of days to retain Session Logs in CloudWatch | `number` | `30` | no |
| cloudwatch\_log\_group\_name | Name of the CloudWatch Log Group for storing SSM Session Logs | `string` | `/ssm/session-logs` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |
| vpc\_id | VPC ID to deploy endpoints to | `string` | `null` | no |
| enable\_log\_to\_s3 | Enable Session Manager to Log to S3 | `bool` | `true` | no |
| enable\_log\_to\_cloudwatch | Enable Session Manager to Log to CloudWatch Logs | `bool` | `true` | no |
| vpc\_endpoints\_enabled | Create VPC Endpoints | `bool` | `false` | no |



## Outputs
| Name |  Example Value | Description |
|------|----------------|-------------|
| session_logs_bucket_name | my-session-logs | S3 bucket for session logs |
| access_log_bucket_name | my-session-access-logs | S3 bucket for S3 access logs |
| cloudwatch_log_group_arn | arn:aws:logs:us-west-2:123456789012:log-group:/ssm/session-logs:* | CloudWatch Log group for session logs |
| kms_key_arn | arn:aws:kms:us-west-2:123456789012:key/2320fbba-d4e5-420d-82d3-1a4d6b8605e8 | KMS Key Arn for Encrypting logs and session | 
| iam_role_arn | arn:aws:iam::123456789012:role/ssm_role | IAM Role for EC2 instances |
| iam_profile_name | ssm_profile | EC2 instance profile for SSM | 
| ssm_security_group | ["sg-05e4f4cf12db5a191"] | Security Group used to access VPC Endpoints |
| vpc_endpoint_ssm | ["vpce-0cefc23e81d365733"] | VPC Endpoint for SSM | 
| vpc_endpoint_ec2messages | ["vpce-0f507468fb9b06b8b"] | VPC Endpoint for EC2 Messages |
| vpc_endpoint_ssmmessages | ["vpce-0fe2cb670d40ec053"] | VPC Endpoint for SSM Messages |
| vpc_endpoint_s3 | ["vpce-0a8ebde94fa301a4a"] | VPC Endpoint for S3 |
| vpc_endpoint_logs | ["vpce-08c90d8df9ef37f90"] | VPC Endpoint for CloudWatch Logs |
| vpc_endpoint_kms | ["vpce-07ddc11beac1d4a3f"] | VPC Endpoint for KMS |


## SSM Usage Example

* Launch an instance using the ssm_profile created by Terraform
* Install the session-manager-plugin and start a session

```
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


