#!/bin/bash

# AWS credentials file path
AWS_CREDENTIALS_FILE=~/.aws/credentials
PROFILE_NAME=My_terraform
AWS_REGION=us-east-1
ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)


# Use AWS CLI to get temporary credentials
TEMP_CREDENTIALS=$(aws sts assume-role --role-arn arn:aws:iam::$ACCOUNT_ID:role/service-role/codebuild-My-Terraform-Project-Dev-service-role --role-session-name CodeBuildSession)

# Extracting the temporary credentials
AWS_ACCESS_KEY_ID=$(echo "$TEMP_CREDENTIALS" | jq -r .Credentials.AccessKeyId)
AWS_SECRET_ACCESS_KEY=$(echo "$TEMP_CREDENTIALS" | jq -r .Credentials.SecretAccessKey)
AWS_SESSION_TOKEN=$(echo "$TEMP_CREDENTIALS" | jq -r .Credentials.SessionToken)

aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID --profile $PROFILE_NAME
aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY --profile $PROFILE_NAME
aws configure set aws_session_token $AWS_SESSION_TOKEN --profile $PROFILE_NAME 

# Optional: Add the region to the new profile
if [ -n "$AWS_REGION" ]; then
  echo "region = $AWS_REGION" >> "$AWS_CREDENTIALS_FILE"
fi

echo "Profile '$PROFILE_NAME' added to AWS credentials file."
