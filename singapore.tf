module "sin_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.sin_vpc_name
  cidr = var.sin_vpc_cidr

  azs             = data.aws_availability_zones.sin.names
  private_subnets = [cidrsubnet(var.sin_vpc_cidr, 3, 0), cidrsubnet(var.sin_vpc_cidr, 3, 1), cidrsubnet(var.sin_vpc_cidr, 3, 2)]
  public_subnets  = [cidrsubnet(var.sin_vpc_cidr, 3, 3), cidrsubnet(var.sin_vpc_cidr, 3, 4), cidrsubnet(var.sin_vpc_cidr, 3, 5)]

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

resource "aws_security_group" "sin_workload_security_group" {
  name        = "singapore-sg"
  vpc_id      = module.sin_vpc.vpc_id
  description = "Network boundary for Workloads in SIN Region"

  tags = {
    Environment : var.environment
  }
}

resource "aws_security_group_rule" "sin_ingress_allow_http_from_sin" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = [var.nrt_vpc_cidr]
  security_group_id = aws_security_group.sin_workload_security_group.id
}

resource "aws_security_group_rule" "sin_egress_allow_all_to_any" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sin_workload_security_group.id
}

resource "aws_instance" "sin_workload" {
  ami                    = data.aws_ami.sin_amazon_linux_2.id
  instance_type          = "t3.small"
  subnet_id              = module.sin_vpc.private_subnets.0
  vpc_security_group_ids = [aws_security_group.sin_workload_security_group.id]
  iam_instance_profile   = aws_iam_instance_profile.workload_instance_profile.name
  user_data              = templatefile("${path.module}/templates/init.tpl", {})

  tags = {
    Environment : var.environment
  }
}

resource "aws_ec2_transit_gateway" "sin_tgw" {
  description     = "Singapore Transit Gateway"
  amazon_side_asn = 64512
  tags = {
    Name : "sin-tgw"
    Environment : var.environment
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "sin_tgw_attachment" {
  subnet_ids         = module.sin_vpc.private_subnets
  transit_gateway_id = aws_ec2_transit_gateway.sin_tgw.id
  vpc_id             = module.sin_vpc.vpc_id
  tags = {
    Name : "sin-tgw-vpc"
    Environment : var.environment
  }
}
