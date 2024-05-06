resource "aws_iam_role" "My_ecs_instance_role" {
  name = var.ecs_instance_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
      },
    ],
  })

  managed_policy_arns = [
    #    format("arn:aws:iam::%s:policy/service-role/CodeBuildBasePolicy-${var.codebuild_s3_bucket_name}-eu-north-1", data.aws_caller_identity.current.account_id),
    "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonElasticContainerRegistryPublicFullAccess",
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "arn:aws:iam::aws:policy/IAMFullAccess"
  ]
}


resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.cluster_name

  tags = {
    TerraformManaged = true
  }
}

resource "aws_ecs_capacity_provider" "this" {
  name = var.capacity_provider

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.autoscaling_group.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      maximum_scaling_step_size = var.maximum_scaling_step_size
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 90
    }
  }
  tags = {
    TerraformManaged = true
  }
}

resource "aws_ecs_cluster_capacity_providers" "my_cluster_capacity_providers" {
  cluster_name       = aws_ecs_cluster.ecs_cluster.name
  capacity_providers = [aws_ecs_capacity_provider.this.name]
}


## Auto scaling group from cluster provide

# modules/autoscaling_group/main.tf

resource "aws_iam_instance_profile" "instance_profile" {
  name = "${var.instance_profile}"
  role = aws_iam_role.My_ecs_instance_role.name
}

resource "aws_launch_template" "launch_template" {
  name                   = var.launch_template_name
  image_id               = data.aws_ami.amazon_linux.id
  instance_type          = var.launch_template_instance_type
  user_data              = var.user_data_script # Read the shell script file
  key_name               = var.key_name         # Use the key_name property of the data source
  vpc_security_group_ids = var.security_group_ids
  # ebs_optimized          = true


  block_device_mappings {
    device_name = "/dev/xvda"

    ebs {
      volume_size = var.ebs_volume_size
      volume_type = var.ebs_volume_type
      encrypted   = var.enable_encryption
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name # Use the name property of the IAM instance profile resource
  }

  # monitoring {
  #   enabled = true
  # }

}

resource "aws_autoscaling_group" "autoscaling_group" {
  name                  = var.asg_name
  min_size              = var.min_size
  max_size              = var.max_size
  desired_capacity      = var.desired_capacity
  vpc_zone_identifier   = var.subnet_ids
  protect_from_scale_in = true

  mixed_instances_policy {

    instances_distribution {
      on_demand_base_capacity                  = var.on_demand_capacity
      # on_demand_allocation_strategy = "prioritized"
      on_demand_percentage_above_base_capacity = 0
      spot_allocation_strategy                 = "capacity-optimized"
      spot_max_price                           = var.spot_max_price
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.launch_template.id
        version            = "$Latest"
      }
    }

  }

  tag {
    key                 = "Name"
    value               = var.launch_template_name
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }

}
