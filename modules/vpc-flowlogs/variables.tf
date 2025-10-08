variable "flow_logs_traffic_type" {
  description = "Traffic type to log: ALL | ACCEPT | REJECT"
  type        = string
  default     = "ALL"
}

variable "flow_logs_retention_days" {
  description = "CloudWatch Logs retention (days)"
  type        = number
  default     = 14
}

variable "flow_logs_kms_key_id" {
  description = "Optional KMS Key ARN for CloudWatch Log encryption"
  type        = string
  default     = null
}

variable "vpc_name" {
    type = string
}

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
