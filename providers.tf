terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  alias   = "sg"
  region  = var.sg
  profile = var.aws_profile
}

provider "aws" {
  alias   = "au"
  region  = var.au
  profile = var.aws_profile
}

provider "aws" {
  alias   = "jp"
  region  = var.jp
  profile = var.aws_profile
}