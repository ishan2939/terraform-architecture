terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.46.0"
    }
  }
}
provider "aws" {
  profile                  = "My_terraform"
  shared_credentials_files = ["~/.aws/credentials"]
  region                   = var.region
}
