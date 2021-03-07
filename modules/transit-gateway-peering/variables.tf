variable "local_name" {
  type = string
  default = "local"
}

variable "peer_name" {
  type = string
  default = "peer"
}

variable "peer_region" {
  type = string
  description = "Peer Region"
}

variable "peer_transit_gateway_id" {
  type = string
  description = "Peert Transit Gateway id"
}

variable "transit_gateway_id" {
  type = string
  description = "Transit Gateway id"
}

variable "local_transit_gateway_association_default_route_table_id" {
  type = string
}

variable "peer_transit_gateway_association_default_route_table_id" {
  type = string
}

variable "local_route_table_ids" {
  type = list(string)
}

variable "peer_route_table_ids" {
  type = list(string)
}

variable "local_vpc_cidr" {
  type = string
  description = "Local VPC CIDR"
}

variable "peer_vpc_cidr" {
  type = string
  description = "Peer VPC CIDR"
}

variable "tags" {
  type = map(string)
  default = {}
}
