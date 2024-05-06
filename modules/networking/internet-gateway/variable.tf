variable "tags" {
  description = "Tags to be applied to resources (inclusive)"
  type = object({
    environment = string
    project     = string
  })
}

variable "extra_tags" {
  description = "extra tags to be applied to resources (in addition to the tags above)"
  type        = map(string)
  default     = {}
}

variable "ig-name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default = ""
}