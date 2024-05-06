output "task_definition_arns" {
  value = {
      arn = aws_ecs_task_definition.task_definition.arn
  }
}

# output "service_ids" {
#   value = {
#       id = aws_ecs_service.ecs_service.id
#   }
# }

# output "target_group_arn" {
#   value = aws_lb_target_group.this.arn
# }

# output "http_listner_arn" {
#   value = aws_lb_listener.http_listner[0].arn
# }