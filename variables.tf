variable "environment" {
  type = string
  default = "dev"
  description = "Environment name"
}

variable "sin_vpc_name" {
  type = string
  default = "sin-vpc"
  description = "VPC name in Singapore region"
}

variable "sin_vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
  description = "VPC CIDR in Singapore region"
}

variable "nrt_vpc_name" {
  type = string
  default = "nrt-vpc"
  description = "VPC name in Tokyo region"
}

variable "nrt_vpc_cidr" {
  type = string
  default = "10.1.0.0/16"
  description = "VPC CIDR in Tokyo region"
}