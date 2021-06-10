resource "aws_security_group" "server" {
  name        = "${var.environment}-Server-Security-Group"
  description = "Server security group"
  vpc_id      = data.terraform_remote_state.net.outputs.vpc_id

  ingress {
    cidr_blocks = var.ssh_cidr
    description = "Allow incoming SSH connections"
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outgoing traffic"
    from_port   = 0
    protocol    = "-1"
    to_port     = 0
  }

  tags = {
    "dmc:environment-type" = var.environment
    "dmc:provisioned-by"   = "Terraform"
    "dmc:provisioned-on"   = local.provisioned_date
    "Name"                 = "${var.environment}-Server-Security-Group"
  }

  lifecycle {
    ignore_changes = [
      tags["dmc:provisioned-on"]
    ]
  }
}
