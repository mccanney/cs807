variable "region" {
  description = "The region where the infrastructure should be deployed."
  type        = string
  default     = "eu-west-2"
}

variable "vpc_cidr_block" {
  description = "The base CIDR block for the VPC."
  type        = string
  default     = "10.10.0.0/16"
}

variable "environment" {
  description = "The name of the environment."
  type        = string
  default     = "Strathclyde-CS807"
}
