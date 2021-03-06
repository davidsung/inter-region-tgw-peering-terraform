output "vpc_id" {
  value = module.vpc.vpc_id
}

output "linux_instance_id" {
  value = module.compute_linux.instance_id
}

output "windows_instance_id" {
  value = module.compute_windows_server.instance_id
}

output "windows_ami_id" {
  value = module.compute_windows_server.ami_id
}