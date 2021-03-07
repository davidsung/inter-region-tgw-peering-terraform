// Local to Peer Inter Region Peering
resource "aws_ec2_transit_gateway_peering_attachment" "tgw_peering" {
  provider                = aws.local
  peer_region             = var.peer_region
  peer_transit_gateway_id = var.peer_transit_gateway_id
  transit_gateway_id      = var.transit_gateway_id
  tags = merge(
    {
      Name : "${var.local_name}-${var.peer_name}-tgw-peering"
    },
    var.tags
  )
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "tgw_peering_acceptor" {
  provider                      = aws.peer
  transit_gateway_attachment_id = aws_ec2_transit_gateway_peering_attachment.tgw_peering.id
  tags = merge(
    {
      Name : "${var.peer_name}-${var.local_name}-tgw-peering"
    },
    var.tags
  )
}

// Route Peer VPC CIDR to Local Transit Gateway
resource "aws_ec2_transit_gateway_route" "peer_tgw_route_in_local" {
  provider                       = aws.local
  destination_cidr_block         = var.peer_vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.tgw_peering.id
  transit_gateway_route_table_id = var.local_transit_gateway_association_default_route_table_id
  depends_on                     = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_acceptor]
}

// Update Peer routes in Local route table
resource "aws_route" "peer_route_in_local" {
  provider               = aws.local
  count                  = length(var.local_route_table_ids)
  route_table_id         = var.local_route_table_ids[count.index]
  destination_cidr_block = var.peer_vpc_cidr
  transit_gateway_id     = var.transit_gateway_id
  depends_on             = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_acceptor]
}

// Route Local VPC CIDR to Peer Transit Gateway
resource "aws_ec2_transit_gateway_route" "local_tgw_route_in_peer" {
  provider                       = aws.peer
  destination_cidr_block         = var.local_vpc_cidr
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_acceptor.id
  transit_gateway_route_table_id = var.peer_transit_gateway_association_default_route_table_id
  depends_on                     = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_acceptor]
}

// Update Local routes in Peer route table
resource "aws_route" "local_route_in_peer" {
  provider               = aws.peer
  count                  = length(var.peer_route_table_ids)
  route_table_id         = var.peer_route_table_ids[count.index]
  destination_cidr_block = var.local_vpc_cidr
  transit_gateway_id     = var.peer_transit_gateway_id
  depends_on             = [aws_ec2_transit_gateway_peering_attachment_accepter.tgw_peering_acceptor]
}
