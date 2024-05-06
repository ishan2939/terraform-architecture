variable "ingress_rules" {
  type = list(any)
  default = [  ]
}

variable "vpc_id" {
  type = string
  description = "id of vpc"
}
variable "sg_name" {
  type = string
  
}

variable "egress_rules" {
  type = list(any)
  default = [  ]
}

variable "sg_description" {
  type = string
  default = "value"
}