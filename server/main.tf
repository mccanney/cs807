locals {
  provisioned_date = formatdate("DD MMM YYYY hh:mm ZZZ", timestamp())
}

data "terraform_remote_state" "net" {
  backend = "s3"

  config = {
    bucket = "terraform-remote-state-bucket-s3"
    key    = "cs807_network/terraform.tfstate"
    region = var.region
  }
}

resource "aws_key_pair" "this" {
  key_name   = lower(var.environment)
  public_key = file("${path.module}/public.key")
}

resource "aws_spot_instance_request" "this" {
  ami                         = "ami-0704763e1339aae7e"
  associate_public_ip_address = true
  availability_zone           = "${var.region}b"
  instance_type               = "p3.2xlarge"
  key_name                    = aws_key_pair.this.id
  spot_price                  = "1.90"
  spot_type                   = "one-time"
  subnet_id                   = "subnet-08a6c5d7f2ae9ab7f"
  vpc_security_group_ids      = [aws_security_group.server.id]
  wait_for_fulfillment        = true

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    encrypted             = true
    volume_size           = 100
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }

  tags = {
    "dmc:environment-type" = var.environment
    "dmc:provisioned-by"   = "Terraform"
    "dmc:provisioned-on"   = local.provisioned_date
    "Name"                 = "${var.environment}-Server"
  }

  lifecycle {
    ignore_changes = [
      tags["dmc:provisioned-on"]
    ]
  }
}
