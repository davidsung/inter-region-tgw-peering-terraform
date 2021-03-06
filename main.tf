module "mercury" {
  source = "./modules/planet"

  providers = {
    aws = aws.mercury
  }

  name                    = "mercury"
  vpc_cidr                = var.mercury_vpc_cidr
  instance_type           = var.instance_type
  network_interface_count = var.eni_count
  key_name                = var.key_name
  icmp_enabled            = var.icmp_allowed
  icmp_whitelist_cidrs    = [var.earth_vpc_cidr, var.mars_vpc_cidr, var.venus_vpc_cidr]
  rdp_enabled             = var.rdp_enabled
  asn                     = 64515

  tags = {
    Environment = var.environment
  }
}
