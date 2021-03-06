module "earth_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.earth_vpc_name
  cidr = var.earth_vpc_cidr

  azs             = data.aws_availability_zones.earth.names
  private_subnets = [cidrsubnet(var.earth_vpc_cidr, 3, 0), cidrsubnet(var.earth_vpc_cidr, 3, 1), cidrsubnet(var.earth_vpc_cidr, 3, 2)]
  public_subnets  = [cidrsubnet(var.earth_vpc_cidr, 3, 3), cidrsubnet(var.earth_vpc_cidr, 3, 4), cidrsubnet(var.earth_vpc_cidr, 3, 5)]

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

resource "aws_security_group" "earth_workload_security_group" {
  name        = "earth-sg"
  vpc_id      = module.earth_vpc.vpc_id
  description = "Network boundary for Workloads in Earth Region"

  tags = {
    Environment : var.environment
  }
}

resource "aws_security_group_rule" "earth_ingress_allow_rdp_from_whitelist" {
  count             = var.rdp_enabled ? 1 : 0
  type              = "ingress"
  from_port         = 3389
  to_port           = 3389
  protocol          = "tcp"
  cidr_blocks       = [var.rdp_whitelist_cidr]
  security_group_id = aws_security_group.earth_workload_security_group.id
}

resource "aws_security_group_rule" "earth_ingress_allow_app_port_from_mars" {
  type              = "ingress"
  from_port         = var.app_port
  to_port           = var.app_port
  protocol          = "tcp"
  cidr_blocks       = [var.mars_vpc_cidr]
  security_group_id = aws_security_group.earth_workload_security_group.id
}

resource "aws_security_group_rule" "earth_ingress_allow_app_port_from_venus" {
  type              = "ingress"
  from_port         = var.app_port
  to_port           = var.app_port
  protocol          = "tcp"
  cidr_blocks       = [var.venus_vpc_cidr]
  security_group_id = aws_security_group.earth_workload_security_group.id
}

// Allow icmp
resource "aws_security_group_rule" "earth_ingress_allow_icmp_from_mars" {
  count             = var.icmp_allowed ? 1 : 0
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = [var.mars_vpc_cidr]
  security_group_id = aws_security_group.earth_workload_security_group.id
}

resource "aws_security_group_rule" "earth_ingress_allow_icmp_from_venus" {
  count             = var.icmp_allowed ? 1 : 0
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  cidr_blocks       = [var.venus_vpc_cidr]
  security_group_id = aws_security_group.earth_workload_security_group.id
}

resource "aws_security_group_rule" "earth_egress_allow_all_to_any" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.earth_workload_security_group.id
}

module "earth_linux" {
  source                 = "./modules/ssm-ec2"
  instance_type          = var.instance_type
  subnet_id              = module.earth_vpc.public_subnets.0
  vpc_security_group_ids = [aws_security_group.earth_workload_security_group.id]
  iam_instance_profile   = module.ssm_instance_profile.instance_profile_name
  user_data              = templatefile("${path.module}/templates/init.tpl", {})

  tags = {
    Name        = "Linux"
    Environment = var.environment
  }
}

module "earth_windows_server" {
  source                 = "./modules/ssm-ec2"
  instance_type          = var.instance_type
  ami                    = data.aws_ami.earth_windows_server.id
  subnet_id              = module.earth_vpc.public_subnets.0
  vpc_security_group_ids = [aws_security_group.earth_workload_security_group.id]
  eni_count              = var.eni_count
  iam_instance_profile   = module.ssm_instance_profile.instance_profile_name
  key_name               = var.key_name

  tags = {
    Name        = data.aws_ami.earth_windows_server.name
    Environment = var.environment
  }
}

resource "aws_ec2_transit_gateway" "earth_tgw" {
  description     = "Earth Transit Gateway"
  amazon_side_asn = var.earth_asn
  tags = {
    Name        = "earth-tgw"
    Environment = var.environment
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "earth_tgw_attachment" {
  subnet_ids         = module.earth_vpc.private_subnets
  transit_gateway_id = aws_ec2_transit_gateway.earth_tgw.id
  vpc_id             = module.earth_vpc.vpc_id
  tags = {
    Name        = "earth-tgw-vpc"
    Environment = var.environment
  }
}
