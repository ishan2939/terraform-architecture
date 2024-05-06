# Terraform Boilerplate

## Description

This Terraform boilerplate provides a foundation for your infrastructure-as-code projects. Follow the steps below to integrate it into your Terraform repository.

### Prepare your Terraform Repository

- Copy all files from this boilerplate to your Terraform repository.
- Replace placeholders in the code with your specific configurations.
  - [REGION] - Region name in which you want terraform to deploy your infrastructure
  - [TERRAFORM_STATE_BUCKET_NAME] - Bucket name which stores your terraform state files
  - [TERRAFORM_VARIABLE_BUCKET_NAME] - Bucket to store your terraform.tfvars file (environment wise)
  - [TERRAFORM_VARIABLE_BUCKET_PATH] - Folder name which you are going to create under [TERRAFORM_VARIABLE_BUCKET_NAME] bucket (Majorly Environemnt wise folders will be there)

## Run Locally (Not Recommended)

- Create a profile under AWS in ~/.aws/credentials with the name aws-terraform-profile.
- Create or select a workspace.
- Create a module folder at the root of your source code.
- Copy the modules you want to use.
- Run the following Terraform commands:

```
terraform init
terraform plan
terraform apply
```

## Run in AWS CodePipeline (Recommended)

- Create a CodeBuild service role and define the trust relationship. For trust relationships you can copy and paste the below code in your existing code build role's trust relationships.

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "codebuild.amazonaws.com",
                "AWS": "arn:aws:iam::{ACCOUNT_ID}:role/service-role/{CODEBUILD_SERVICE_ROLE_NAME}"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```

- Assign this role to CodeBuild.
- Replace the service role placeholder in the code with your role name.
- Upload your build spec file based on your environment to CodeBuild.
- Copy and paste your environment wise terraform.tfvar file under [TERRAFORM_VARIABLE_BUCKET_NAME]/[TERRAFORM_VARIABLE_BUCKET_PATH] s3 bucket path

**Note**: We do not commit the terraform.tfvars file to the source repo.
Instead, store it in an S3 bucket under each environment's folder.
