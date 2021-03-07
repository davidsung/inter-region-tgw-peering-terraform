variable "name" {
  type = string
}

// VPC
variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "tags" {
  type = map(string)
  default = {}
}

// Compute
variable "instance_type" {
  type = string
  default = "t3.small"
}

variable "key_name" {
  type = string
  default = null
}

variable "network_interface_count" {
  type = number
  default = 1
}

// Security Group
variable "app_port" {
  type = number
  default = 80
}

variable "app_protocol" {
  type = string
  default = "tcp"
}

variable "app_whitelist_cidrs" {
  type = list(string)
  default = null
}

variable "rdp_whitelist_cidrs" {
  type = list(string)
  default = null
}

variable "icmp_whitelist_cidrs" {
  type = list(string)
  default = null
}

// Transit Gateway
variable "asn" {
  type = number
  default = 64512
}
