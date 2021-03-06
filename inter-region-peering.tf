// Earth to Mars Inter Region Peering
resource "aws_ec2_transit_gateway_peering_attachment" "earth_mars_tgw_peering" {
  peer_region             = var.mars_region
  peer_transit_gateway_id = aws_ec2_transit_gateway.mars_tgw.id
  transit_gateway_id      = aws_ec2_transit_gateway.earth_tgw.id
  tags = {
    Name : "mars-earth-tgw-peering"
    Environment : var.environment
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "mars_earth_tgw_peering_acceptor" {
  provider                      = aws.mars
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.earth_mars_tgw_peering.id
  tags = {
    Name : "earth-mars-tgw-peering"
    Environment : var.environment
  }
}

// Earth to Venus Inter Region Peering
resource "aws_ec2_transit_gateway_peering_attachment" "earth_venus_tgw_peering" {
  peer_region             = var.venus_region
  peer_transit_gateway_id = aws_ec2_transit_gateway.venus_tgw.id
  transit_gateway_id      = aws_ec2_transit_gateway.earth_tgw.id
  tags = {
    Name : "earth-venus-tgw-peering"
    Environment : var.environment
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "venus_earth_tgw_peering_acceptor" {
  provider                      = aws.venus
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.earth_venus_tgw_peering.id
  tags = {
    Name : "venus-earth-tgw-peering"
    Environment : var.environment
  }
}

// Earth to Mars
resource "aws_ec2_transit_gateway_route" "mars_tgw_route_in_earth" {
  destination_cidr_block         = var.mars_vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.earth_mars_tgw_peering.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.earth_tgw.association_default_route_table_id
  depends_on                     = [aws_ec2_transit_gateway_peering_attachment_accepter.mars_earth_tgw_peering_acceptor]
}

resource "aws_route" "mars_route_in_earth" {
  count                  = length(module.earth_vpc.public_route_table_ids)
  route_table_id         = module.earth_vpc.public_route_table_ids[count.index]
  destination_cidr_block = var.mars_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.earth_tgw.id
  depends_on             = [aws_ec2_transit_gateway_peering_attachment_accepter.mars_earth_tgw_peering_acceptor]
}

// Mars to Earth
resource "aws_ec2_transit_gateway_route" "earth_tgw_route_in_mars" {
  provider                       = aws.mars
  destination_cidr_block         = var.earth_vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.mars_earth_tgw_peering_acceptor.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.mars_tgw.association_default_route_table_id
  depends_on                     = [aws_ec2_transit_gateway_peering_attachment_accepter.mars_earth_tgw_peering_acceptor]
}

resource "aws_route" "earth_route_in_mars" {
  provider               = aws.mars
  count                  = length(module.mars_vpc.public_route_table_ids)
  route_table_id         = module.mars_vpc.public_route_table_ids[count.index]
  destination_cidr_block = var.earth_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.mars_tgw.id
  depends_on             = [aws_ec2_transit_gateway_peering_attachment_accepter.mars_earth_tgw_peering_acceptor]
}

// Earth to Venus
resource "aws_ec2_transit_gateway_route" "venus_tgw_route_in_earth" {
  destination_cidr_block         = var.venus_vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.earth_mars_tgw_peering.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.earth_tgw.association_default_route_table_id
  depends_on                     = [aws_ec2_transit_gateway_peering_attachment_accepter.venus_earth_tgw_peering_acceptor]
}

resource "aws_route" "venus_route_in_earth" {
  count                  = length(module.earth_vpc.public_route_table_ids)
  route_table_id         = module.earth_vpc.public_route_table_ids[count.index]
  destination_cidr_block = var.venus_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.earth_tgw.id
  depends_on             = [aws_ec2_transit_gateway_peering_attachment_accepter.venus_earth_tgw_peering_acceptor]
}

// Venus to Earth
resource "aws_ec2_transit_gateway_route" "earth_tgw_route_in_venus" {
  provider                       = aws.venus
  destination_cidr_block         = var.earth_vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.venus_earth_tgw_peering_acceptor.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.venus_tgw.association_default_route_table_id
  depends_on                     = [aws_ec2_transit_gateway_peering_attachment_accepter.venus_earth_tgw_peering_acceptor]
}

resource "aws_route" "earth_route_in_venus" {
  provider               = aws.venus
  count                  = length(module.venus_vpc.public_route_table_ids)
  route_table_id         = module.venus_vpc.public_route_table_ids[count.index]
  destination_cidr_block = var.earth_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.venus_tgw.id
  depends_on             = [aws_ec2_transit_gateway_peering_attachment_accepter.venus_earth_tgw_peering_acceptor]
}

// Mars to Venus Inter Region Peering
resource "aws_ec2_transit_gateway_peering_attachment" "mars_venus_tgw_peering" {
  provider                = aws.mars
  peer_region             = var.venus_region
  peer_transit_gateway_id = aws_ec2_transit_gateway.venus_tgw.id
  transit_gateway_id      = aws_ec2_transit_gateway.mars_tgw.id
  tags = {
    Name : "mars-venus-tgw-peering"
    Environment : var.environment
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "venus_mars_tgw_peering_acceptor" {
  provider                      = aws.venus
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.mars_venus_tgw_peering.id
  tags = {
    Name : "venus-mars-tgw-peering"
    Environment : var.environment
  }
}

// Mars to Venus
resource "aws_ec2_transit_gateway_route" "venus_tgw_route_in_mars" {
  provider                       = aws.mars
  destination_cidr_block         = var.venus_vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.venus_mars_tgw_peering_acceptor.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.mars_tgw.association_default_route_table_id
  depends_on                     = [aws_ec2_transit_gateway_peering_attachment_accepter.venus_mars_tgw_peering_acceptor]
}

resource "aws_route" "venus_route_in_mars" {
  provider               = aws.mars
  count                  = length(module.mars_vpc.public_route_table_ids)
  route_table_id         = module.mars_vpc.public_route_table_ids[count.index]
  destination_cidr_block = var.venus_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.mars_tgw.id
  depends_on             = [aws_ec2_transit_gateway_peering_attachment_accepter.venus_mars_tgw_peering_acceptor]
}

// Venus to Mars
resource "aws_ec2_transit_gateway_route" "mars_tgw_route_in_venus" {
  provider                       = aws.venus
  destination_cidr_block         = var.mars_vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.venus_mars_tgw_peering_acceptor.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.venus_tgw.association_default_route_table_id
  depends_on                     = [aws_ec2_transit_gateway_peering_attachment_accepter.venus_mars_tgw_peering_acceptor]
}

resource "aws_route" "mars_route_in_venus" {
  provider               = aws.venus
  count                  = length(module.venus_vpc.public_route_table_ids)
  route_table_id         = module.venus_vpc.public_route_table_ids[count.index]
  destination_cidr_block = var.mars_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.venus_tgw.id
  depends_on             = [aws_ec2_transit_gateway_peering_attachment_accepter.venus_mars_tgw_peering_acceptor]
}