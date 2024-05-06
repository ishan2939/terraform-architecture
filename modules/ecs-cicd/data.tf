data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_codestarconnections_connection" "connection"{
    arn = "arn:aws:codestar-connections:us-east-1:654654485151:connection/f8aea87c-5179-497a-8f82-65ef1289cd63"    
}