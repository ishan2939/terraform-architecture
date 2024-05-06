# modules/alb/variables.tf

variable "alb_name" {
  description = "Name of the ALB"
  type        = string
  
}

variable "alb_subnets" {
  description = "List of subnet IDs where the ALB should be deployed"
  type        = list(string)
}

variable "alb_security_groups" {
  description = "List of security group IDs for the ALB"
  type        = list(string)
}

variable "is_internal" {
  type = bool
  default = false
}

variable "vpc_id" {
  type = string
}

variable "default_tg_name" {
  type = string
  default = "Default_TG"
}

# variable "certificate_arn" {
#   type = string
# }