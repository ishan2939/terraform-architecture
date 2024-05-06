output "vpc_id" {
  description = "The ID of the VPC"
  value       = try(aws_vpc.my_vpc.id, null)
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = try(aws_vpc.my_vpc.arn, null)
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = try(aws_vpc.my_vpc.cidr_block, null)
}

output "vpc_owner_id" {
  description = "The ID of the AWS account that owns the VPC"
  value       = try(aws_vpc.my_vpc.owner_id, null)
}
