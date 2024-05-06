
terraform {
    backend "s3" {
        bucket = "myterraformbucketishan"
        dynamodb_table = "terraform-state-lock-dynamo"
        key = "myterraformbucketishan/terraform.tfstate"
        region = "us-east-1"
        profile = "My_terraform"
    }
}