locals {
  rdp = {
    port = 3389
    protocol = "tcp"
  }
  icmp = {
    port = -1
    protocol = "icmp"
  }
}

resource "aws_security_group" "compute_security_group" {
  name        = "${var.name}-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Network boundary for compute instance"

  tags = var.tags
}

resource "aws_security_group_rule" "ingress_allow_rdp" {
  count             = var.rdp_whitelist_cidrs != null ? 1 : 0
  type              = "ingress"
  from_port         = local.rdp.port
  to_port           = local.rdp.port
  protocol          = local.rdp.protocol
  cidr_blocks       = var.rdp_whitelist_cidrs
  security_group_id = aws_security_group.compute_security_group.id
}

resource "aws_security_group_rule" "ingress_allow_app_port" {
  count             = var.app_whitelist_cidrs != null ? 1 : 0
  type              = "ingress"
  from_port         = var.app_port
  to_port           = var.app_port
  protocol          = var.app_protocol
  cidr_blocks       = var.app_whitelist_cidrs
  security_group_id = aws_security_group.compute_security_group.id
}

// Allow icmp
resource "aws_security_group_rule" "ingress_allow_icmp" {
  count             = var.icmp_whitelist_cidrs != null ? 1 : 0
  type              = "ingress"
  from_port         = local.icmp.port
  to_port           = local.icmp.port
  protocol          = local.icmp.protocol
  cidr_blocks       = var.icmp_whitelist_cidrs
  security_group_id = aws_security_group.compute_security_group.id
}

resource "aws_security_group_rule" "egress_allow_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.compute_security_group.id
}

module "ssm_instance_profile" {
  source = "../ssm-instance-profile"
}

data "aws_ami" "windows_server" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base*"]
  }

  owners = ["amazon"]
}

module "compute_linux" {
  source                 = "../ssm-ec2"
  instance_type          = var.instance_type
  subnet_id              = module.vpc.public_subnets.0
  vpc_security_group_ids = [aws_security_group.compute_security_group.id]
  iam_instance_profile   = module.ssm_instance_profile.instance_profile_name
  user_data              = templatefile("${path.module}/templates/init.tpl", {})

  tags = merge(
    var.tags,
    {
      Name        = "Amazon Linux 2"
    }
  )
}

module "compute_windows_server" {
  source                 = "../ssm-ec2"
  instance_type          = var.instance_type
  ami                    = data.aws_ami.windows_server.id
  subnet_id              = module.vpc.public_subnets.0
  vpc_security_group_ids = [aws_security_group.compute_security_group.id]
  eni_count              = var.network_interface_count
  iam_instance_profile   = module.ssm_instance_profile.instance_profile_name
  key_name               = var.key_name

  tags = merge(
    var.tags,
    {
      Name        = data.aws_ami.windows_server.name
    }
  )
}
