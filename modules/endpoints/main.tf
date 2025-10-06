#S3 gateway endpoint
resource "aws_vpc_endpoint" "s3_gateway_endpoint" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.ap-southeast-5.s3"
  tags         = merge(var.tags, { Name = "${var.resource_name_prefix}-s3-gateway-endpoint" })
}

resource "aws_vpc_endpoint" "s3_interface_endpoint" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-southeast-5.s3"
  vpc_endpoint_type = "Interface"

  security_group_ids = var.security_group_ids
  subnet_ids         = var.subnet_ids

  private_dns_enabled = true
  tags                = merge(var.tags, { Name = "${var.resource_name_prefix}-s3-interface-endpoint" })

  depends_on = [aws_vpc_endpoint.s3_gateway_endpoint]

}

# resource "aws_vpc_endpoint" "ssm_interface_endpoint" {
#   vpc_id            = var.vpc_id
#   service_name      = "com.amazonaws.ap-southeast-5.ssm"
#   vpc_endpoint_type = "Interface"

# security_group_ids = var.security_group_ids
#   subnet_ids = var.subnet_ids

#   

#   private_dns_enabled = true
#   tags                = merge(var.tags, { Name = "${var.resource_name_prefix}-ssm-interface-endpoint" })

# }



# resource "aws_vpc_endpoint" "ec2_interface_endpoint" {
#   vpc_id            = var.vpc_id
#   service_name      = "com.amazonaws.ap-southeast-5.ec2"
#   vpc_endpoint_type = "Interface"

# security_group_ids = var.security_group_ids
#   subnet_ids = var.subnet_ids

#   private_dns_enabled = true
#   tags                = merge(var.tags, { Name = "${var.resource_name_prefix}-ec2-interface-endpoint" })

# }


# resource "aws_vpc_endpoint" "ssmmessages_interface_endpoint" {
#   vpc_id            = var.vpc_id
#   service_name      = "com.amazonaws.ap-southeast-5.ssmmessages"
#   vpc_endpoint_type = "Interface"

# security_group_ids = var.security_group_ids
#   subnet_ids = var.subnet_ids

#   private_dns_enabled = true
#   tags                = merge(var.tags, { Name = "${var.resource_name_prefix}-ssmmessages-interface-endpoint" })

# }


# resource "aws_vpc_endpoint" "ec2messages_interface_endpoint" {
#   vpc_id            = var.vpc_id
#   service_name      = "com.amazonaws.ap-southeast-5.ec2messages"
#   vpc_endpoint_type = "Interface"

# security_group_ids = var.security_group_ids
#   subnet_ids = var.subnet_ids
#   private_dns_enabled  = true
#   tags                 = merge(var.tags, { Name = "${var.resource_name_prefix}-ec2messages-interface-endpoint" })
# }


