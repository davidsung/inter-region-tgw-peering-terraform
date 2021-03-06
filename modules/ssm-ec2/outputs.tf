output "instance_id" {
  value = aws_instance.this.id
}

output "ami_id" {
  value = data.aws_ami.amazon_linux_2.id
}

output "private_dns" {
  value = aws_instance.this.private_dns
}

output "private_ip" {
  value = aws_instance.this.private_ip
}

output "public_dns" {
  value = aws_instance.this.public_dns
}

output "public_ip" {
  value = aws_instance.this.public_ip
}

//output "enis" {
//  value = data.aws_network_interfaces.eni.*
//}
