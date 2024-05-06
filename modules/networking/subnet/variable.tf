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

variable "subnet-name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "assign_ipv6_address_on_creation" {
  description = "Assign IPv6 address on creation"
  type        = bool
  default     = false
}

variable "availability_zone" {
  description = "Availability zone"
  type        = string
  default     = null
}

variable "availability_zone_id" {
  description = "Availability zone ID"
  type        = string
  default     = null
}

variable "cidr_block" {
  description = "CIDR block"
  type        = string
}

variable "enable_dns64" {
  description = "Enable DNS64"
  type        = bool
  default     = false
}

variable "enable_resource_name_dns_aaaa_record_on_launch" {
  description = "Enable resource name DNS AAAA record on launch"
  type        = bool
  default     = false
}

variable "enable_resource_name_dns_a_record_on_launch" {
  description = "Enable resource name DNS A record on launch"
  type        = bool
  default     = false
}

variable "ipv6_cidr_block" {
  description = "IPv6 CIDR block"
  type        = string
  default     = null
}

variable "ipv6_native" {
  description = "IPv6 native"
  type        = bool
  default     = false
}

variable "map_public_ip_on_launch" {
  description = "Specify true to indicate that instances launched into the subnet should be assigned a public IP address. "
  type        = bool
  default     = false
}

variable "private_dns_hostname_type_on_launch" {
  description = "Private DNS hostname type on launch"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
