module "venus_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  providers = {
    aws = aws.venus
  }

  name = var.venus_vpc_name
  cidr = var.venus_vpc_cidr

  azs             = data.aws_availability_zones.venus.names
  private_subnets = [cidrsubnet(var.venus_vpc_cidr, 3, 0), cidrsubnet(var.venus_vpc_cidr, 3, 1), cidrsubnet(var.venus_vpc_cidr, 3, 2)]
  public_subnets  = [cidrsubnet(var.venus_vpc_cidr, 3, 3), cidrsubnet(var.venus_vpc_cidr, 3, 4), cidrsubnet(var.venus_vpc_cidr, 3, 5)]

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

resource "aws_security_group" "venus_workload_security_group" {
  provider    = aws.venus
  name        = "venus-sg"
  vpc_id      = module.venus_vpc.vpc_id
  description = "Network boundary for Workloads in Venus"

  tags = {
    Environment = var.environment
  }
}

resource "aws_security_group_rule" "venus_ingress_allow_rdp_from_whitelist" {
  provider          = aws.venus
  count             = var.rdp_enabled ? 1 : 0
  type              = "ingress"
  from_port         = 3389
  to_port           = 3389
  protocol          = "tcp"
  cidr_blocks       = [var.rdp_whitelist_cidr]
  security_group_id = aws_security_group.venus_workload_security_group.id
}

// Allow app_port
resource "aws_security_group_rule" "venus_ingress_allow_app_port_from_earth" {
  provider          = aws.venus
  type              = "ingress"
  from_port         = var.app_port
  to_port           = var.app_port
  protocol          = "tcp"
  cidr_blocks       = [var.earth_vpc_cidr]
  security_group_id = aws_security_group.venus_workload_security_group.id
}

resource "aws_security_group_rule" "venus_ingress_allow_app_port_from_mars" {
  provider          = aws.venus
  type              = "ingress"
  from_port         = var.app_port
  to_port           = var.app_port
  protocol          = "tcp"
  cidr_blocks       = [var.mars_vpc_cidr]
  security_group_id = aws_security_group.venus_workload_security_group.id
}

// Allow icmp
resource "aws_security_group_rule" "venus_ingress_allow_icmp_from_mars" {
  provider          = aws.venus
  count             = var.icmp_allowed ? 1 : 0
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = [var.mars_vpc_cidr]
  security_group_id = aws_security_group.venus_workload_security_group.id
}

resource "aws_security_group_rule" "venus_ingress_allow_icmp_from_earth" {
  provider          = aws.venus
  count             = var.icmp_allowed ? 1 : 0
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = [var.earth_vpc_cidr]
  security_group_id = aws_security_group.venus_workload_security_group.id
}

// Allow all egress
resource "aws_security_group_rule" "venus_egress_allow_all_to_any" {
  provider          = aws.venus
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.venus_workload_security_group.id
}

module "venus_linux" {
  source = "./modules/ssm-ec2"

  providers = {
    aws = aws.venus
  }

  instance_type          = var.instance_type
  subnet_id              = module.venus_vpc.public_subnets.0
  vpc_security_group_ids = [aws_security_group.venus_workload_security_group.id]
  iam_instance_profile   = module.ssm_instance_profile.instance_profile_name
  user_data              = templatefile("${path.module}/templates/init.tpl", {})

  tags = {
    Name        = "Linux"
    Environment = var.environment
  }
}

module "venus_windows_server" {
  source = "./modules/ssm-ec2"

  providers = {
    aws = aws.venus
  }

  instance_type          = var.instance_type
  ami                    = data.aws_ami.venus_windows_server.id
  subnet_id              = module.venus_vpc.public_subnets.0
  vpc_security_group_ids = [aws_security_group.venus_workload_security_group.id]
  eni_count              = var.eni_count
  iam_instance_profile   = module.ssm_instance_profile.instance_profile_name
  key_name               = var.key_name

  tags = {
    Name        = data.aws_ami.venus_windows_server.name
    Environment = var.environment
  }
}

resource "aws_ec2_transit_gateway" "venus_tgw" {
  provider        = aws.venus
  description     = "Venus Transit Gateway"
  amazon_side_asn = var.venus_asn
  tags = {
    Name        = "venus-tgw"
    Environment = var.environment
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "venus_tgw_attachment" {
  provider           = aws.venus
  subnet_ids         = module.venus_vpc.private_subnets
  transit_gateway_id = aws_ec2_transit_gateway.venus_tgw.id
  vpc_id             = module.venus_vpc.vpc_id
  tags = {
    Name        = "venus-tgw-vpc"
    Environment = var.environment
  }
}
