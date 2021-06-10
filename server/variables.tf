variable "region" {
  description = "The region where the infrastructure should be deployed."
  type        = string
  default     = "eu-west-2"
}

variable "environment" {
  description = "The name of the environment."
  type        = string
  default     = "Strathclyde-CS807"
}

variable "ssh_cidr" {
  description = "CIDR blocks allowed to connect to the instance via SSH."
  type        = list(string)
}
