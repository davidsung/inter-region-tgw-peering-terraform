output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_public_route_table_ids" {
  value = module.vpc.public_route_table_ids
}

output "vpc_private_route_table_ids" {
  value = module.vpc.private_route_table_ids
}

output "linux_instance_id" {
  value = module.compute_linux.instance_id
}

output "linux_network" {
  value = {
    private_ip = module.compute_linux.private_ip
    public_ip = module.compute_linux.public_ip
  }
}

output "windows_instance_id" {
  value = module.compute_windows_server.instance_id
}

output "windows_ami_id" {
  value = module.compute_windows_server.ami_id
}

output "windows_network" {
  value = {
    private_ip = module.compute_windows_server.private_ip
    public_ip = module.compute_windows_server.public_ip
  }
}

output "transit_gateway_id" {
  value = aws_ec2_transit_gateway.tgw.id
}

output "transit_gateway_association_default_route_table_id" {
  value = aws_ec2_transit_gateway.tgw.association_default_route_table_id
}

output "transit_gateway_vpc_attachment" {
  value = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment.id
}
