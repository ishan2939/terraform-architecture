resource "aws_nat_gateway" "ng" {
  allocation_id = var.allocation_id
  subnet_id = var.subnet_id
  tags = merge(
    {
      Name = var.ng-name
      Environment = var.tags.environment
      Project = var.tags.project
    },
    var.extra_tags
  )
}
