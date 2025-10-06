
#vpc
variable "vpc_cidr" {
  type = string
}

variable "public_subnet_a_cidr" {
  type = string
}

variable "public_subnet_b_cidr" {
  type = string
}

variable "private_subnet_a_cidr" {
  type = string
}

variable "private_subnet_b_cidr" {
  type = string
}
variable "private_tgw_subnet_a_cidr" {
  type = string
}

variable "private_tgw_subnet_b_cidr" {
  type = string
}


variable "availability_zones" {
  type    = list(string)
  default = ["ap-southeast-5a", "ap-southeast-5b"]
}

#tgw
variable "tgw_id" {
  type = string
}


#tagging

variable "tags" {
  type = map(string)
}

variable "resource_name_prefix" {
  type = string
}

