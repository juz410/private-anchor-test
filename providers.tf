terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.14.1"
    }
  }
}

provider "aws" {
  region  = "ap-southeast-5"
  profile = "GAP_Admin-Anchor_Testbed"
}
