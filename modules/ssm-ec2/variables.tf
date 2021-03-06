variable "subnet_id" {
  type = string
  description = "Subnet ID for EC2 Instance"
}

variable "vpc_security_group_ids" {
  type = list(string)
  description = "VPC Security Group IDs"
}

variable "environment" {
  type = string
  description = "Environment"
  default = "staging"
}

variable "instance_type" {
  type = string
  description = "EC2 Instance Type"
  default = "t3.small"
}

variable "ami" {
  type = string
  description = "AMI for EC2 Instance"
  default = null
}

variable "key_name" {
  type = string
  description = "Key Pair Name"
  default = null
}


variable "iam_instance_profile" {
  type = string
  description = "IAM Instance Profile"
  default = null
}

variable "private_ip" {
  type = string
  description = "Private IP"
  default = null
}

variable "eni_count" {
  type = number
  description = "Number of ENI required"
  default = 1
}

variable "user_data" {
  type = string
  description = "EC2 Instance User Data"
  default = null
}

variable "tags" {
  type = map(string)
  default = {}
}
