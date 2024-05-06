variable "tags" {
  description = "Tags to be applied to resources (inclusive)"
  type = object({
    environment = string
    project     = string
  })
}

variable "extra_tags" {
  description = "extra tags to be applied to resources."
  type        = map(string)
  default     = {}
}

variable "eip-name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  
}

variable "domain" {
  description = "Indicates if this EIP is for use in VPC (vpc)."
  type = string
  default = "vpc"
}