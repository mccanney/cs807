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

variable "instance_type" {
  description = "The size and type of the instance."
  type        = string
  default     = "t2.micro"
}
