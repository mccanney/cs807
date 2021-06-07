locals {
  provisioned_date = formatdate("DD MMM YYYY hh:mm ZZZ", timestamp())
}

data "terraform_remote_state" "net" {
  backend = "s3"

  config {
    bucket = "terraform-remote-state-bucket-s3"
    key    = "cs807_network/terraform.tfstate"
    region = var.region
  }
}

resource "aws_key_pair" "this" {
  key_name   = lower(var.environment)
  public_key = file("${path.module}/public.key")
}

resource "aws_instance" "this" {
  ami                         = var.ami_id
  associate_public_ip_address = true
  availability_zone           = "${var.region}a"
  iam_instance_profile        = ""
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.this.id
  subnet_id                   = data.terraform_remote_state.net.outputs.jh
  vpc_security_group_ids      = aws_security_group.server.id

  ebs_block_device {
    delete_on_termination = true
    device_name           = "/dev/sda1"
    encrypted             = true
    volume_size           = 10
  }

  metadata_options {
    http_endpoint               = true
    http_put_response_hop_limit = 1
    http_tokens                 = "required"
  }

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
