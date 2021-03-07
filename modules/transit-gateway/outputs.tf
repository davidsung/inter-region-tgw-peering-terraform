output "transit_gateway_id" {
  value = aws_ec2_transit_gateway.tgw.id
}

output "transit_gateway_vpc_attachment_id" {
  value = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment.id
}

output "transit_gateway_association_default_route_table_id" {
  value = aws_ec2_transit_gateway.tgw.association_default_route_table_id
}
