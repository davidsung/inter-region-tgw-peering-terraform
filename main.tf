module "earth" {
  source = "./modules/planet"

  providers = {
    aws = aws.earth
  }

  name                    = "earth"
  vpc_cidr                = var.earth_vpc_cidr
  instance_type           = var.instance_type
  network_interface_count = var.network_interface_count
  key_name                = var.key_name
  icmp_whitelist_cidrs    = [var.mars_vpc_cidr, var.venus_vpc_cidr]
  rdp_whitelist_cidrs     = [var.rdp_whitelist_cidr]
  nginx_whitelist_cidrs   = [var.mars_vpc_cidr, var.venus_vpc_cidr]

  tags = {
    Environment = var.environment
  }
}

module "earth_transit_gateway" {
  source = "./modules/transit-gateway"

  providers = {
    aws = aws.earth
  }

  name       = "earth"
  vpc_id     = module.earth.vpc_id
  subnet_ids = module.earth.vpc_public_subnets
  asn        = var.earth_asn

  tags = {
    Environment = var.environment
  }
}

module "mars" {
  source = "./modules/planet"

  providers = {
    aws = aws.mars
  }

  name                    = "mars"
  vpc_cidr                = var.mars_vpc_cidr
  instance_type           = var.instance_type
  network_interface_count = var.network_interface_count
  key_name                = var.key_name
  icmp_whitelist_cidrs    = [var.earth_vpc_cidr, var.venus_vpc_cidr]
  rdp_whitelist_cidrs     = [var.rdp_whitelist_cidr]
  nginx_whitelist_cidrs   = [var.mars_vpc_cidr, var.venus_vpc_cidr]

  tags = {
    Environment = var.environment
  }
}

module "mars_transit_gateway" {
  source = "./modules/transit-gateway"

  providers = {
    aws = aws.mars
  }

  name       = "mars"
  vpc_id     = module.mars.vpc_id
  subnet_ids = module.mars.vpc_public_subnets
  asn        = var.mars_asn

  tags = {
    Environment = var.environment
  }
}

module "venus" {
  source = "./modules/planet"

  providers = {
    aws = aws.venus
  }

  name                    = "venus"
  vpc_cidr                = var.venus_vpc_cidr
  instance_type           = var.instance_type
  network_interface_count = var.network_interface_count
  key_name                = var.key_name
  icmp_whitelist_cidrs    = [var.earth_vpc_cidr, var.mars_vpc_cidr]
  rdp_whitelist_cidrs     = [var.rdp_whitelist_cidr]
  nginx_whitelist_cidrs   = [var.mars_vpc_cidr, var.venus_vpc_cidr]

  tags = {
    Environment = var.environment
  }
}

module "venus_transit_gateway" {
  source = "./modules/transit-gateway"

  providers = {
    aws = aws.venus
  }

  name       = "venus"
  vpc_id     = module.venus.vpc_id
  subnet_ids = module.venus.vpc_public_subnets
  asn        = var.venus_asn

  tags = {
    Environment = var.environment
  }
}

module "earth_mars_peering" {
  source = "./modules/transit-gateway-peering"

  providers = {
    aws.local = aws.earth
    aws.peer  = aws.mars
  }

  peer_name                                               = "mars"
  peer_region                                             = var.mars_region
  peer_vpc_cidr                                           = var.mars_vpc_cidr
  peer_transit_gateway_id                                 = module.mars_transit_gateway.transit_gateway_id
  peer_route_table_ids                                    = module.mars.vpc_public_route_table_ids
  peer_transit_gateway_association_default_route_table_id = module.mars_transit_gateway.transit_gateway_association_default_route_table_id

  local_name                                               = "earth"
  local_vpc_cidr                                           = var.earth_vpc_cidr
  transit_gateway_id                                       = module.earth_transit_gateway.transit_gateway_id
  local_route_table_ids                                    = module.earth.vpc_public_route_table_ids
  local_transit_gateway_association_default_route_table_id = module.earth_transit_gateway.transit_gateway_association_default_route_table_id
}

module "mars_venus_peering" {
  source = "./modules/transit-gateway-peering"

  providers = {
    aws.local = aws.mars
    aws.peer  = aws.venus
  }

  peer_name                                               = "venus"
  peer_region                                             = var.venus_region
  peer_vpc_cidr                                           = var.venus_vpc_cidr
  peer_transit_gateway_id                                 = module.venus_transit_gateway.transit_gateway_id
  peer_route_table_ids                                    = module.venus.vpc_public_route_table_ids
  peer_transit_gateway_association_default_route_table_id = module.venus_transit_gateway.transit_gateway_association_default_route_table_id

  local_name                                               = "mars"
  local_vpc_cidr                                           = var.mars_vpc_cidr
  transit_gateway_id                                       = module.mars_transit_gateway.transit_gateway_id
  local_route_table_ids                                    = module.mars.vpc_public_route_table_ids
  local_transit_gateway_association_default_route_table_id = module.mars_transit_gateway.transit_gateway_association_default_route_table_id
}

module "venus_earth_peering" {
  source = "./modules/transit-gateway-peering"

  providers = {
    aws.local = aws.venus
    aws.peer  = aws.earth
  }

  peer_name                                               = "earth"
  peer_region                                             = var.earth_region
  peer_vpc_cidr                                           = var.earth_vpc_cidr
  peer_transit_gateway_id                                 = module.earth_transit_gateway.transit_gateway_id
  peer_route_table_ids                                    = module.earth.vpc_public_route_table_ids
  peer_transit_gateway_association_default_route_table_id = module.earth_transit_gateway.transit_gateway_association_default_route_table_id

  local_name                                               = "venus"
  local_vpc_cidr                                           = var.venus_vpc_cidr
  transit_gateway_id                                       = module.venus_transit_gateway.transit_gateway_id
  local_route_table_ids                                    = module.venus.vpc_public_route_table_ids
  local_transit_gateway_association_default_route_table_id = module.venus_transit_gateway.transit_gateway_association_default_route_table_id
}
