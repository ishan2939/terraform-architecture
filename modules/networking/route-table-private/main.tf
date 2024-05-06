resource "aws_route_table" "rt" {
  vpc_id = var.vpc_id
  
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.nat_gateway_id
  }

  tags = merge(
    {
      Name          = var.rt-name
      "Environment" = var.tags.environment,
      "Project"     = var.tags.project
    },
    var.extra_tags
  )
}

resource "aws_route_table_association" "rt-association" {

  subnet_id      = var.subnet_id
  route_table_id = aws_route_table.rt.id
}

