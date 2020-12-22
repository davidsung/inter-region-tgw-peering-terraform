resource "aws_ec2_transit_gateway_peering_attachment" "sin_nrt_tgw_peering" {
  peer_region             = "ap-northeast-1"
  peer_transit_gateway_id = aws_ec2_transit_gateway.nrt_tgw.id
  transit_gateway_id      = aws_ec2_transit_gateway.sin_tgw.id
  tags = {
    Name : "sin-nrt-tgw-peering"
    Environment : var.environment
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "nrt_sin_tgw_peering_acceptor" {
  provider                      = aws.nrt
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.sin_nrt_tgw_peering.id
  tags = {
    Name : "nrt-sin-tgw-peering"
    Environment : var.environment
  }
}

resource "aws_ec2_transit_gateway_route" "sin_tgw_route" {
  destination_cidr_block         = var.nrt_vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.sin_nrt_tgw_peering.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.sin_tgw.association_default_route_table_id
  depends_on                     = [aws_ec2_transit_gateway_peering_attachment_accepter.nrt_sin_tgw_peering_acceptor]
}

resource "aws_ec2_transit_gateway_route" "nrt_tgw_route" {
  provider                       = aws.nrt
  destination_cidr_block         = var.sin_vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.nrt_sin_tgw_peering_acceptor.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway.nrt_tgw.association_default_route_table_id
  depends_on                     = [aws_ec2_transit_gateway_peering_attachment_accepter.nrt_sin_tgw_peering_acceptor]
}

resource "aws_route" "nrt_route_in_sin" {
  count                  = length(module.sin_vpc.private_route_table_ids)
  route_table_id         = module.sin_vpc.private_route_table_ids[count.index]
  destination_cidr_block = var.nrt_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.sin_tgw.id
  depends_on             = [aws_ec2_transit_gateway_peering_attachment_accepter.nrt_sin_tgw_peering_acceptor]
}

resource "aws_route" "sin_route_in_nrt" {
  provider               = aws.nrt
  count                  = length(module.nrt_vpc.private_route_table_ids)
  route_table_id         = module.nrt_vpc.private_route_table_ids[count.index]
  destination_cidr_block = var.sin_vpc_cidr
  transit_gateway_id     = aws_ec2_transit_gateway.nrt_tgw.id
  depends_on             = [aws_ec2_transit_gateway_peering_attachment_accepter.nrt_sin_tgw_peering_acceptor]
}