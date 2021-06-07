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
    "Name"                 = "${var.environment}-VPC"
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
    "Name"                 = "Public Subnet (${each.key})"
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
    "Name"                 = "Internet Gateway"
  }

  lifecycle {
    ignore_changes = [
      tags["dmc:provisioned-on"]
    ]
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    "dmc:environment-type" = var.environment
    "dmc:provisioned-by"   = "Terraform"
    "dmc:provisioned-on"   = local.provisioned_date
    "Name"                 = "Public Route Table"
  }

  lifecycle {
    ignore_changes = [
      tags["dmc:provisioned-on"]
    ]
  }
}

resource "aws_route_table_association" "public" {
  for_each = local.az_details

  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public[each.key].id
}
