## data for ecs auto scalling group

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"     # Amazon linux 2023 ECS Optimized
    values = ["amzn2-ami-ecs-hvm-2.0.20240328-x86_64-ebs"]  
  }
}

