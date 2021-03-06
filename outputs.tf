output "earth_region" {
  value = var.earth_region
}

output "mars_region" {
  value = var.mars_region
}

output "venus_region" {
  value = var.venus_region
}

output "earth_vpc_id" {
  value = module.earth_vpc.vpc_id
}

output "mars_vpc_id" {
  value = module.mars_vpc.vpc_id
}

output "venus_vpc_id" {
  value = module.venus_vpc.vpc_id
}

output "earth_tgw_id" {
  value = aws_ec2_transit_gateway.earth_tgw.id
}

output "mars_tgw_id" {
  value = aws_ec2_transit_gateway.mars_tgw.id
}

output "venus_tgw_id" {
  value = aws_ec2_transit_gateway.venus_tgw.id
}

output "earth_linux_instance_id" {
  value = module.earth_linux.instance_id
}

output "earth_linux_network" {
  value = {
    private_ip : module.earth_linux.private_ip
    public_ip : module.earth_linux.public_ip
  }
}

output "earth_windows_instance_id" {
  value = module.earth_windows_server.instance_id
}

output "earth_windows_network" {
  value = {
    private_ip : module.earth_windows_server.private_ip
    public_ip : module.earth_windows_server.public_ip
  }
}

output "mars_linux_instance_id" {
  value = module.mars_linux.instance_id
}

output "mars_linux_network" {
  value = {
    private_ip : module.mars_linux.private_ip
    public_ip : module.mars_linux.public_ip
  }
}

output "mars_windows_instance_id" {
  value = module.mars_windows_server.instance_id
}

output "mars_windows_network" {
  value = {
    private_ip : module.mars_windows_server.private_ip
    public_ip : module.mars_windows_server.public_ip
  }
}

output "venus_linux_instance_id" {
  value = module.venus_linux.instance_id
}

output "venus_linux_network" {
  value = {
    private_ip : module.venus_linux.private_ip
    public_ip : module.venus_linux.public_ip
  }
}

output "venus_windows_instance_id" {
  value = module.venus_windows_server.instance_id
}

output "venus_windows_network" {
  value = {
    private_ip : module.venus_windows_server.private_ip
    public_ip : module.venus_windows_server.public_ip
  }
}
