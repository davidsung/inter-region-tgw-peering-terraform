terraform {
  required_version = ">= 0.12.26"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.21.0"
    }
  }
}

provider "aws" {
  alias  = "mars"
  region = var.mars_region
}

provider "aws" {
  alias  = "venus"
  region = var.venus_region
}

provider "aws" {
  region = var.earth_region
}

provider "aws" {
  alias  = "mercury"
  region = "ap-southeast-1"
}