variable "name" {
  type = string
}

variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "iam_instance_profile" {
  type = string
}

variable "associate_public_ip" {
  type    = bool
  default = false # default: no public IP
}

variable "key_name" {
  type    = string
  default = null # default: no key specified
}

variable "private_ip" {
  type    = string
  default = null # default: let AWS assign
}

variable "secondary_private_ips" {
  type    = list(string)
  default = null # default: none
}

variable "source_dest_check" {
  type    = bool
  default = true # AWS default
}

variable "enable_detailed_monitoring" {
  type    = bool
  default = false # default: basic monitoring
}

variable "disable_api_termination" {
  type    = bool
  default = false # AWS default (termination allowed)
}

variable "enable_hibernation" {
  type    = bool
  default = false
}

variable "placement_tenancy" {
  type    = string
  default = "default" # AWS default ("dedicated"/"host" require special accounts/hosts)
}

# Root volume settings
variable "root_volume_size" {
  type    = number
  default = 30
}

variable "root_volume_type" {
  type    = string
  default = "gp3"
}

variable "root_volume_throughput" {
  type    = number
  default = 125
}

variable "root_volume_iops" {
  type    = number
  default = 3000
}

variable "root_delete_on_termination" {
  type    = bool
  default = true # AWS default: true
}

variable "root_kms_key_id" {
  type    = string
  default = null # use account/default EBS encryption; don't force a custom KMS key
}

# Optional extra EBS volumes; each item can omit fields and the module will default them.
variable "ebs_block_devices" {
  type = list(object({
    device_name           = string
    volume_size           = optional(number)
    volume_type           = optional(string)
    iops                  = optional(number)
    throughput            = optional(number)
    encrypted             = optional(bool)
    kms_key_id            = optional(string)
    delete_on_termination = optional(bool) # defaults to true in the resource via try(...)
  }))
  default = [] # no extra EBS volumes by default
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "user_data" {
  type    = string
  default = ""
}

#backups
variable "backup_tag_prefix" {
  type    = string
  default = "anchor-backup" # results in keys like aws-backup:hourly
}

variable "backup_8hourly" {
  type    = bool
  default = false
}

variable "backup_12hourly" {
  type    = bool
  default = false
}

variable "backup_daily" {
  type    = bool
  default = false
}

variable "backup_weekly" {
  type    = bool
  default = false
}

variable "backup_monthly" {
  type    = bool
  default = false
}

variable "backup_yearly" {
  type    = bool
  default = false
}