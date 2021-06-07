terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.40.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-remote-state-bucket-s3"
    dynamodb_table = "terraform-remote-state-dynamo-lock"
    encrypt        = true
    key            = "cs807_server/terraform.tfstate"
    region         = "eu-west-2"
  }

  required_version = ">= 0.15.0"
}
