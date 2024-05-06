resource "aws_eip" "elastic-ip" {
  domain = var.domain
  tags = merge(
    {
      Name = var.eip-name
      Environment = var.tags.environment
      Project = var.tags.project
    },
    var.extra_tags
  )
}