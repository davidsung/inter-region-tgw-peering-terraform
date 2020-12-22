module "nrt_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  providers = {
    aws = aws.nrt
  }

  name = var.nrt_vpc_name
  cidr = var.nrt_vpc_cidr

  azs             = data.aws_availability_zones.nrt.names
  private_subnets = [cidrsubnet(var.nrt_vpc_cidr, 3, 0), cidrsubnet(var.nrt_vpc_cidr, 3, 1), cidrsubnet(var.nrt_vpc_cidr, 3, 2)]
  public_subnets  = [cidrsubnet(var.nrt_vpc_cidr, 3, 3), cidrsubnet(var.nrt_vpc_cidr, 3, 4), cidrsubnet(var.nrt_vpc_cidr, 3, 5)]

  enable_ipv6                                    = true
  private_subnet_ipv6_prefixes                   = [0, 1, 2]
  private_subnet_assign_ipv6_address_on_creation = true

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_vpn_gateway   = false
  enable_dns_hostnames = true

  tags = {
    Environment = var.environment
  }
}

resource "aws_security_group" "nrt_workload_security_group" {
  provider    = aws.nrt
  name        = "tokyo-sg"
  vpc_id      = module.nrt_vpc.vpc_id
  description = "Network boundary for Workloads in NRT Region"

  tags = {
    Environment : var.environment
  }
}

resource "aws_security_group_rule" "nrt_ingress_allow_http_from_nrt" {
  provider          = aws.nrt
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.sin_vpc_cidr]
  security_group_id = aws_security_group.nrt_workload_security_group.id
}

resource "aws_security_group_rule" "nrt_egress_allow_all_to_any" {
  provider          = aws.nrt
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nrt_workload_security_group.id
}

resource "aws_instance" "nrt_workload" {
  provider               = aws.nrt
  ami                    = data.aws_ami.nrt_amazon_linux_2.id
  instance_type          = "t3.small"
  subnet_id              = module.nrt_vpc.private_subnets.0
  vpc_security_group_ids = [aws_security_group.nrt_workload_security_group.id]
  iam_instance_profile   = aws_iam_instance_profile.workload_instance_profile.name
  user_data              = templatefile("${path.module}/templates/init.tpl", {})

  tags = {
    Environment : var.environment
  }
}

resource "aws_ec2_transit_gateway" "nrt_tgw" {
  provider        = aws.nrt
  description     = "Tokyo Transit Gateway"
  amazon_side_asn = 64513
  tags = {
    Name : "nrt-tgw"
    Environment : var.environment
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "nrt_tgw_attachment" {
  provider           = aws.nrt
  subnet_ids         = module.nrt_vpc.private_subnets
  transit_gateway_id = aws_ec2_transit_gateway.nrt_tgw.id
  vpc_id             = module.nrt_vpc.vpc_id
  tags = {
    Name : "nrt-tgw-vpc"
    Environment : var.environment
  }
}
