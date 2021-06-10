variable "ami_name" {
  description = "The name of AMI."
  type        = string
}

locals {
  timestamp = formatdate("DD-MMM-YYYY hhmm.ss ZZZ", timestamp())
}

source "amazon-ebs" "server" {
  ami_description        = "Ubuntu Server 20.04 with Hashcat."
  ami_name               = "${var.ami_name} (${local.timestamp})"
  block_duration_minutes = 60
  communicator           = "ssh"
  region                 = "eu-west-2"
  spot_instance_types    = ["c4.xlarge"]
  spot_price             = "auto"
  ssh_interface          = "public_ip"
  ssh_username           = "ubuntu"

  # Get the latest version of Ubuntu 20 server
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-2021*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }

    most_recent = true
    owners      = ["679593333241"]
  }

  tags = {
    "Name"               = "${var.ami_name} (${local.timestamp})"
    "dmc:platform"       = "Strathclyde-CS807"
    "dmc:provisioned-by" = "Packer"
    "dmc:provisioned-on" = local.timestamp
  }
}

build {
  sources = ["source.amazon-ebs.server"]

  provisioner "ansible" {
    galaxy_file          = "playbooks/requirements.yml"
    galaxy_force_install = true
    playbook_file        = "playbooks/playbook.yml"
  }
}
