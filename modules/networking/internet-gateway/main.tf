resource "aws_internet_gateway" "ig" {
  vpc_id = var.vpc_id

  tags = merge(
    {
      Name          = var.ig-name
      "Environment" = var.tags.environment,
      "Project"     = var.tags.project
    },
    var.extra_tags
  )
}
