data "aws_availability_zones" "sin" {}

data "aws_availability_zones" "nrt" {
  provider = aws.nrt
}

data "aws_ami" "sin_amazon_linux_2" {
  most_recent = true

  filter {
   name   = "owner-alias"
   values = ["amazon"]
  }

  filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
  }

  owners = ["amazon"]
}

data "aws_ami" "nrt_amazon_linux_2" {
  provider = aws.nrt
  most_recent = true

  filter {
   name   = "owner-alias"
   values = ["amazon"]
  }

  filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
  }

  owners = ["amazon"]
}
