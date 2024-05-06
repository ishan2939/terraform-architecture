output "id" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.subnet.id
}

output "subnet_arns" {
  description = "List of ARNs of public subnets"
  value       = aws_subnet.subnet.arn
}

output "subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = [aws_subnet.subnet.cidr_block]
}

output "subnets_ipv6_cidr_blocks" {
  description = "List of IPv6 cidr_blocks of public subnets in an IPv6 enabled VPC"
  value       = aws_subnet.subnet.ipv6_cidr_block != null ? [aws_subnet.subnet.ipv6_cidr_block] : []
}