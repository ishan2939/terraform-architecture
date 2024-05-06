# resource "aws_lb_target_group" "this" {
#   for_each = toset(var.tg_name)

#   name     = each.value
#   port     = 80
#   protocol = "HTTP"
#   vpc_id   = var.tg_vpc
# }

# resource "aws_lb_listener" "http_listner" {

#   load_balancer_arn = aws_lb.alb.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.this["My-Todo-TG-Frontend-Terraform"].arn
#   }
# }

# resource "aws_lb_listener_rule" "backend_rule" {
#   listener_arn = aws_lb_listener.http_listner.arn
#   priority     = 100

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.this["My-Todo-TG-Backend-Terraform"].arn
#   }

#   condition {
#     path_pattern {
#       values = ["/api/*"]
#     }
#   }
# }

resource "aws_lb_target_group" "this" {
  name     = var.default_tg_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}

resource "aws_lb_listener" "http_listner" {

  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_lb" "alb" {
  name               = var.alb_name
  load_balancer_type = "application"
  internal           = var.is_internal
  subnets            = var.alb_subnets
  security_groups    = var.alb_security_groups
  # Additional ALB configuration goes here
}
