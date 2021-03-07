resource "aws_ec2_transit_gateway" "tgw" {
  description     = "${var.name} transit gateway"
  amazon_side_asn = var.asn
  tags = merge(
    var.tags,
    {
      Name = "${var.name}-tgw"
    }
  )
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment" {
  subnet_ids         = var.subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = var.vpc_id
  tags = merge(
    var.tags,
    {
      Name        = "${var.name}-tgw-vpc"
    }
  )
}
