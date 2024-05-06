# output "http_listner" {
#   value = aws_lb_listener.http_listner.arn
# }

output "http_listner_arn" {
  value = aws_lb_listener.http_listner.arn
}

# output "this" {
#   value = {
#     for key, target_group in aws_lb_target_group.this :
#     key => target_group.arn
#   }
# }

output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "alb_arn" {
  value = aws_lb.alb.arn
}