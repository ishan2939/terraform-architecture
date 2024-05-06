output "route_table_association_ids" {
  description = "List of IDs of the route table association"
  value = aws_route_table_association.rt-association
}

output "route_table_ids" {
  description = "List of IDs of intra route tables"
  value = aws_route_table.rt.id
}
