variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment name"
}

variable "earth_vpc_name" {
  type        = string
  default     = "earth-vpc"
  description = "VPC name in Earth"
}

variable "earth_region" {
  type        = string
  default     = "us-east-1"
  description = "Earth Region"
}

variable "earth_asn" {
  type        = number
  default     = 64512
  description = "Earth Amazon Side ASN"
}

variable "earth_vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC CIDR in Earth"
}

variable "mercury_vpc_cidr" {
  type = string
  default = "10.3.0.0/16"
  description = "VPC CIDR in Mercury"
}

variable "mars_region" {
  type        = string
  default     = "ap-northeast-1"
  description = "Mars Region"
}

variable "mars_asn" {
  type        = number
  default     = 64513
  description = "Mars Amazon Side ASN"
}

variable "mars_vpc_name" {
  type        = string
  default     = "mars-vpc"
  description = "VPC name in Mars"
}

variable "mars_vpc_cidr" {
  type        = string
  default     = "10.1.0.0/16"
  description = "VPC CIDR in Mars"
}

variable "venus_region" {
  type        = string
  default     = "eu-central-1"
  description = "Venus Region"
}

variable "venus_asn" {
  type        = number
  default     = 64514
  description = "Venus Amazon Side ASN"
}

variable "venus_vpc_name" {
  type        = string
  default     = "venus-vpc"
  description = "VPC name in Venus"
}

variable "venus_vpc_cidr" {
  type        = string
  default     = "10.2.0.0/16"
  description = "VPC CIDR in Venus"
}

variable "instance_type" {
  type        = string
  default     = "t3.small"
  description = "EC2 Instance Type in each region"
}

variable "eni_count" {
  type        = number
  default     = 1
  description = "Total ENI(s) attached to EC2 Instance"
}

variable "app_port" {
  type        = number
  default     = 80
  description = "Application port for other instances to reach"
}

variable "key_name" {
  type        = string
  default     = null
  description = "Key Pair Name"
}

variable "icmp_allowed" {
  type        = bool
  default     = true
  description = "Allow ICMP from internal networks"
}

variable "rdp_enabled" {
  type        = bool
  default     = true
  description = "Remote Access allowed from public"
}

variable "rdp_whitelist_cidr" {
  type        = string
  default     = null
  description = "Public IP address with CIDR allowed to remote access Windows instances"
}

