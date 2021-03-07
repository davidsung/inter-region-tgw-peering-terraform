variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "asn" {
  type = number
  default = 64512
}

variable "tags" {
  type = map(string)
  default = {}
}
