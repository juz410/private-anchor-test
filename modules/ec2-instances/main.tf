locals {
  backup_tags = {
    "${var.backup_tag_prefix}8hourly"  = tostring(var.backup_8hourly)
    "${var.backup_tag_prefix}12hourly"  = tostring(var.backup_12hourly)
    "${var.backup_tag_prefix}daily"   = tostring(var.backup_daily)
    "${var.backup_tag_prefix}weekly"  = tostring(var.backup_weekly)
    "${var.backup_tag_prefix}monthly" = tostring(var.backup_monthly)
    "${var.backup_tag_prefix}monthly" = tostring(var.backup_monthly)
  }
}


resource "aws_instance" "this" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  iam_instance_profile        = var.iam_instance_profile
  associate_public_ip_address = var.associate_public_ip
  key_name                    = var.key_name
  private_ip                  = var.private_ip
  secondary_private_ips       = var.secondary_private_ips
  source_dest_check           = var.source_dest_check
  monitoring                  = var.enable_detailed_monitoring
  disable_api_termination     = var.disable_api_termination
  hibernation                 = var.enable_hibernation
  tenancy                     = var.placement_tenancy

  # Root volume
  root_block_device {
    encrypted             = true
    kms_key_id            = var.root_kms_key_id
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    throughput            = var.root_volume_throughput
    iops                  = var.root_volume_iops
    delete_on_termination = var.root_delete_on_termination
  }

  # Extra EBS volumes (optional)
  dynamic "ebs_block_device" {
    for_each = var.ebs_block_devices
    content {
      device_name           = ebs_block_device.value.device_name
      volume_size           = try(ebs_block_device.value.volume_size, null)
      volume_type           = try(ebs_block_device.value.volume_type, null)
      iops                  = try(ebs_block_device.value.iops, null)
      throughput            = try(ebs_block_device.value.throughput, null)
      encrypted             = try(ebs_block_device.value.encrypted, true)
      kms_key_id            = try(ebs_block_device.value.kms_key_id, null)
      delete_on_termination = try(ebs_block_device.value.delete_on_termination, true)
    }
  }

  tags = merge(
    var.tags,
    local.backup_tags,
    { Name = var.name }
  )

  user_data = var.user_data
}

