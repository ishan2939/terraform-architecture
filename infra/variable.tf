variable "region" {
  default = "us-east-1"
}

variable "vpc-name" {
  description = "name of the vpc"
  type        = string
}

variable "tags" {
  description = "tag of the vpc"
  default = {
    environment = "Dev"
    project     = "My-terraform-project"
  }
}

variable "extra_tags" {
  description = "extra tag for the vpc"
}

variable "cidr_block" {
  description = "cide block for vpv"
  type        = string
}

variable "ig-name" {
  description = "internet-gateway name"
}

variable "rt-name" {
  description = "name of route table"
}

variable "ecs_cluster_name" {
  type = string
}

variable "capacity_provider_name" {
  type = string
}

variable "max_scaling_step_size" {
  type    = string
  default = "1"
}

variable "ecs_template_name" {
  type = string
}

variable "ecs_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "ecs_volume_size" {
  type    = number
  default = 30
}

variable "ecs_instance_volume_type" {
  type    = string
  default = "gp3"
}

variable "enable_encryption" {
  type    = bool
  default = false
}

variable "ecs_tag_value" {
  type = string
}

variable "ecs_asg_name" {
  type = string
}

variable "ecs_asg_min_size" {
  type    = number
  default = 1
}

variable "ecs_asg_max_size" {
  type    = number
  default = 2
}

variable "ecs_asg_desired_size" {
  type    = number
  default = 1
}

variable "ecs_on_demand_cap" {
  type    = number
  default = 0
}

variable "ecs_instance_profile_name" {
  type = string
}

variable "ecs_instance_role_name" {
  type = string
}

variable "spot_max_price" {
  type = string
}

variable "ecs_instance_ssh_name" {
  type    = string
  default = ""
}

variable "security_groups" {
  description = "Map of security group configurations"
  type = map(object({
    name        = string
    description = string
    ingress_rules = list(object({
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = list(string)
      description     = string
      security_groups = list(string)
    }))
    egress_rules = list(object({
      from_port       = number
      to_port         = number
      protocol        = string
      cidr_blocks     = list(string)
      description     = string
      security_groups = list(string)
    }))
    tags = map(string)
  }))
}


variable "alb_name" {
  description = "Name of the ALB"
  type        = string
}

# variable "alb_subnets" {
#   description = "List of subnet IDs where the ALB should be deployed"
#   type        = list(string)
# }

# variable "alb_security_groups" {
#   description = "List of security group IDs for the ALB"
#   type        = list(string)
# }

variable "is_internal" {
  type    = bool
  default = false
}

# variable "tg_vpc" {
#   type = string
# }

# variable "alb_tg_name" {
#   type = list(string)
# }

# variable "certificate_arn" {
#   type = string
# }

variable "ng-name" {
  description = "name of nat-gateway"
}

variable "ecs_task_role" {
  type = string
}

variable "ecs_service_role" {
  type = string
}

variable "default_tg_name" {
  type    = string
  default = "aws-target-group"
}

variable "listener_rule_priority" {
  type    = number
  default = 10
}

variable "path_pattern" {
  type    = string
  default = "/api*"
}

variable "host_header" {
  type    = string
  default = "example-site.com"
}

variable "health_check_path" {
  type    = string
  default = "/health-check"
}

variable "health_check_interval" {
  type    = number
  default = 30
}


variable "health_check_timeout" {
  type    = number
  default = 10
}

variable "healthy_threshold" {
  type    = number
  default = 3
}

variable "unhealthy_threshold" {
  type    = number
  default = 3
}

variable "eip-name" {
  description = "name of elastic-ip"
  type        = string
}

variable "ecs_service" {
  description = "Map of ECS service configuration"
  type = map(object({
    ecs_task_role    = string
    ecs_service_role = string
    # ecs_codedeploy_role = string

    # blue_target_name       = string
    # green_target_name      = string
    listener_rule_priority = number
    path_pattern           = string
    host_header            = string
    health_check_path      = string
    health_check_interval  = number
    health_check_timeout   = number
    healthy_threshold      = number
    unhealthy_threshold    = number

    ecs_task_family          = string
    network_mode             = string
    requires_compatibilities = list(string)
    task_cpu                 = number
    task_memory              = number
    cpu                      = number
    softLimit                = number
    hardLimit                = number
    ecs_container_image      = string
    containerPort            = number
    hostPort                 = number
    portName                 = string
    ecs_awslogs_group        = string
    # ecs_region               = string
    ecs_awslogs_stream = string
    ecs_service_name   = string
    # ecs_service_cluster_id   = string
    desired_count       = number
    scheduling_strategy = string
    # awslogs_region           = string
    ecs_container_name = string
    # vpc_id                   = string

    attach_load_balancer = bool
    create_tg            = bool
    create_lr            = bool
    tg-name              = string

    dns_ttl           = number
    dns_type          = string
    service_discovery = bool
    service_connect   = bool


    env_task_defintions = list(object({
      name  = string
      value = string
    }))

    secrets = list(object({
      name      = string
      valueFrom = string
    }))

    # codebuild_project_name = string
    # codebuild_role_name    = string

    create_codepipeline = bool

    buildspec_file_name            = string
    codebuild_repo_policy_name     = string
    codebuild_repo_role_name       = string
    codebuild_repo_project_name    = string
    codebuild_repo_source_version  = string
    codebuild_repo_source_location = string
    codebuild_repo_artifacts_name  = string
    branch_event_type              = string
    branch_head_ref                = string

    # Environment vairables here
    # AWS_DEFAULT_REGION     = string
    # IMAGE_REPO_NAME        = string
    # IMAGE_TAG              = string
    # CONTAINER_NAME         = string
    # PARAMETER_NAME         = string

    # ecs_listener_arns        = string
    ecs_service_cluster_name = string

    codepipeline_name        = string
    codepipeline_policy_name = string
    codepipeline_role_name   = string

    remote_party_owner      = string
    source_version_provider = string
    remote_repo_token       = string
    remote_repo_owner       = string
    remote_repo_name        = string
    remote_branch           = string
    poll_source_changes     = bool
    deployment_timeout      = number
    definition_file_name    = string
  }))
}

variable "s3_bucket" {
  type = map(object({
    bucket             = string
    bucket_environment = string
    bucket_versioning  = string
  }))
}
