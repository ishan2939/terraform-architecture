## variable for ecs cluster
variable "ecs_instance_role_name" {
  type = string
}

variable "cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
}

variable "capacity_provider" {
  type        = string
  description = "capacity_provider for ecs cluster"
}

variable "ecs_asg_arn" {
  type        = string
  default     = ""
  description = "ecs_asg_arn for ecs cluster"
}

variable "maximum_scaling_step_size" {
  type        = string
  default     = "1"
  description = "maximum_scaling_step_size"
}


## variable for asg in ecs cluster

# modules/autoscaling_group/variables.tf

variable "launch_template_name" {
  description = "Name of the Launch Template"
  type        = string
  
}

variable "launch_template_instance_type" {
  description = "Instance type for the Launch Template"
  type        = string
  default = "t3.medium"
}

variable "ebs_volume_size" {
  type        = number
  default     = 30
  description = "instance ebs volume size"
}

variable "ebs_volume_type" {
  type        = string
  default     = "gp3"
  description = "instance ebs volume size"
}

variable "enable_encryption" {
  type        = bool
  default     = false
  description = "enable_encryption for ecs server at rest"
}

variable "user_data_script" {
  description = "User data script for the Launch Template"
  type        = string
}

variable "tag_value" {
  description = "A map of tags to assign to the resources"
  type        = string
  default = "environment"
}

variable "asg_name" {
  type        = string
  description = ""
}

variable "security_group_ids" {
  type = list(string)
}

# variable "ecs_instance_profile_role" {
#   type        = string
#   default     = ""
#   description = "ec2 role for connecting with ecs"
# }


variable "min_size" {
  type        = number
  default     = 1
  description = "minimun instance size for asg"
}

variable "max_size" {
  type        = number
  default     = 2
  description = "maximum instance size for asg"
}

variable "desired_capacity" {
  type        = number
  default     = 1
  description = "desired instance size for asg"
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "on_demand_capacity" {
  type        = number
  default     = 0
  description = "on_demand_capacity for autoscaling group"
}

variable "instance_profile" {
  type        = string
  default     = ""
  description = "instance_profile for ecs server"
}

variable "key_name" {
  type        = string
  default     = ""
  description = "key_pair for ec2 server"
}

variable "spot_max_price" {
  type = string
}






