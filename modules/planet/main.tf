data "aws_availability_zones" "all" {}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.name}-vpc"
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.all.names
  private_subnets = [cidrsubnet(var.vpc_cidr, 3, 0), cidrsubnet(var.vpc_cidr, 3, 1), cidrsubnet(var.vpc_cidr, 3, 2)]
  public_subnets  = [cidrsubnet(var.vpc_cidr, 3, 3), cidrsubnet(var.vpc_cidr, 3, 4), cidrsubnet(var.vpc_cidr, 3, 5)]

  enable_ipv6                                    = true
  private_subnet_ipv6_prefixes                   = [0, 1, 2]
  private_subnet_assign_ipv6_address_on_creation = true

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_vpn_gateway   = false
  enable_dns_hostnames = true

  tags = var.tags
}
