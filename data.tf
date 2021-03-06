data "aws_availability_zones" "earth" {}

data "aws_availability_zones" "mars" {
  provider = aws.mars
}

data "aws_availability_zones" "venus" {
  provider = aws.venus
}

data "aws_ami" "earth_amazon_linux_2" {
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

data "aws_ami" "mars_amazon_linux_2" {
  provider    = aws.mars
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

data "aws_ami" "venus_amazon_linux_2" {
  provider    = aws.venus
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

data "aws_ami" "earth_windows_server" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base*"]
  }

  owners = ["amazon"]
}

data "aws_ami" "mars_windows_server" {
  provider    = aws.mars
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base*"]
  }

  owners = ["amazon"]
}

data "aws_ami" "venus_windows_server" {
  provider    = aws.venus
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base*"]
  }

  owners = ["amazon"]
}