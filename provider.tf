terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.39.0"
    }
  }
  backend "s3" {
    bucket = "comunidadedevops-jefferson"
    key    = "terraform-eks/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}