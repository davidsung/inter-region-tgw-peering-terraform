data "aws_ami" "amazon_linux_2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "this" {
  ami                    = var.ami != null ? var.ami : data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  private_ip             = var.private_ip
  vpc_security_group_ids = var.vpc_security_group_ids
  iam_instance_profile   = var.iam_instance_profile
  user_data              = var.user_data
  key_name               = var.key_name

  tags = merge(var.tags,
    {
      "description" = "Managed by Terraform"
    }
  )
}

resource "aws_network_interface" "this" {
  count = var.eni_count - 1
  subnet_id = var.subnet_id
  security_groups = var.vpc_security_group_ids

  attachment {
    instance = aws_instance.this.id
    device_index = count.index + 1
  }

  tags = merge(var.tags,
    {
      Name = "${aws_instance.this.id}-eni-${count.index}"
    }
  )
}

//data "aws_network_interfaces" "eni" {
//  filter {
//    name = "attachment.instance-id"
//    values = [aws_instance.this.id]
//  }
//}
//
resource "aws_eip" "this" {
  count = var.eni_count - 1
  vpc = true
  network_interface = aws_network_interface.this[count.index].id
}
