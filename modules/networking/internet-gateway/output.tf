output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = try(aws_internet_gateway.ig.id, null)
}

output "igw_arn" {
  description = "The ARN of the Internet Gateway"
  value       = try(aws_internet_gateway.ig.arn, null)
}