variable "bucket" {
  type = string
  description = "name for the bucket."
  
}

variable "bucket_environment" {
  type = string
  description = "environment for the bucket."
  default = "Devlopment"
}

variable "bucket_versioning" {
  type = string
  default = "Enabled"
}