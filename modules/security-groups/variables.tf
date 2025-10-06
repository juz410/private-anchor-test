variable "vpc_id" {
  type = string
}


#tagging

variable "tags" {
  type = map(string)
}

variable "resource_name_prefix" {
  type = string
}