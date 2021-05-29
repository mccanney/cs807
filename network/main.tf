terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.40.0"
    }
  }
  version = ">= 0.15.0"
}

locals {
  provisioned_date = formatdate("DD MMM YYYY hh:mm ZZZ", timestamp())

  az_details = {
    "${var.region}a" = cidrsubnet(var.vpc_cidr_block, 2, 0)
    "${var.region}b" = cidrsubnet(var.vpc_cidr_block, 2, 1)
    "${var.region}c" = cidrsubnet(var.vpc_cidr_block, 2, 2)
  }
}

# Create the VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "dmc:environment-type" = var.environment
    "dmc:provisioned-by"   = "Terraform"
    "dmc:provisioned-on"   = local.provisioned_date
  }

  lifecycle {
    ignore_changes = [
      tags["dmc:provisioned-on"]
    ]
  }
}

# Create public subnets
resource "aws_subnet" "public" {
  for_each = local.az_details

  availability_zone       = each.key
  cidr_block              = cidrsubnet(each.value, 1, 0)
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.main.id

  tags = {
    "dmc:environment-type" = var.environment
    "dmc:provisioned-by"   = "Terraform"
    "dmc:provisioned-on"   = local.provisioned_date
  }

  lifecycle {
    ignore_changes = [
      tags["dmc:provisioned-on"]
    ]
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.main.id

  tags = {
    "dmc:environment-type" = var.environment
    "dmc:provisioned-by"   = "Terraform"
    "dmc:provisioned-on"   = local.provisioned_date
  }

  lifecycle {
    ignore_changes = [
      tags["dmc:provisioned-on"]
    ]
  }
}
