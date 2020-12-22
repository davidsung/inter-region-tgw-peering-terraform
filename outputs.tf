output "sin_vpc_id" {
  value = module.sin_vpc.vpc_id
}

output "nrt_vpc_id" {
  value = module.nrt_vpc.vpc_id
}

output "sin_tgw_id" {
  value = aws_ec2_transit_gateway.sin_tgw.id
}

output "nrt_tgw_id" {
  value = aws_ec2_transit_gateway.nrt_tgw.id
}

output "sin_workload" {
  value = aws_instance.sin_workload.private_ip
}

output "nrt_workload" {
  value = aws_instance.nrt_workload.private_ip
}
