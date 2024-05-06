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

variable "ng-name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
  
}

variable "allocation_id" {
  type        = string
  description = "Allocation ID of the Elastic IP for the NAT gateway"
}

variable "subnet_id" {
  type        = string
  description = "Subnet ID to create the NAT gateway in"
}