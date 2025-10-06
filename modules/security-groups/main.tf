module "external_alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${var.resource_name_prefix}-sg-external-alb"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-external-alb" })

  ingress_with_cidr_blocks = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "Allow HTTP traffic from anywhere"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "Allow HTTPS traffic from anywhere"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "uat_server_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${var.resource_name_prefix}-sg-uat-servers"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-uat-servers" })

  ingress_with_source_security_group_id = [
    {
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      description              = "Allow HTTP from external ALB"
      source_security_group_id = module.external_alb_sg.security_group_id
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "all_in_one_server_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${var.resource_name_prefix}-sg-all-in-one-servers"
  vpc_id = var.vpc_id
  tags   = var.tags

  ingress_with_source_security_group_id = [
    {
      from_port                = 80
      to_port                  = 80
      protocol                 = "tcp"
      description              = "Allow HTTP from external ALB"
      source_security_group_id = module.external_alb_sg.security_group_id
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "interface_endpoint_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${var.resource_name_prefix}-sg-interface-endpoint"
  vpc_id = var.vpc_id
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-interface-endpoint" })

  ingress_with_source_security_group_id = [
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      description              = "Allow HTTPS traffic from UAT servers"
      source_security_group_id = module.uat_server_sg.security_group_id
    },
    {
      from_port                = 443
      to_port                  = 443
      protocol                 = "tcp"
      description              = "Allow HTTPS traffic from All-in-One servers"
      source_security_group_id = module.all_in_one_server_sg.security_group_id
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      description = "Allow all outbound traffic"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}



# resource "aws_security_group" "external_alb_sg" {
#   name   = "${var.resource_name_prefix}-sg-alb"
#   vpc_id = var.vpc_id
#   tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-alb" })
# }

# resource "aws_vpc_security_group_ingress_rule" "external_alb_sg_http_rule" {
#   security_group_id = aws_security_group.external_alb_sg.id
#   ip_protocol       = "tcp"
#   from_port         = 80
#   to_port           = 80
#   cidr_ipv4         = "0.0.0.0/0"
#   description       = "Allow HTTP traffic from anywhere"
#   depends_on        = [aws_security_group.external_alb_sg]
# }

# resource "aws_vpc_security_group_ingress_rule" "external_alb_sg_https_rule" {
#   security_group_id = aws_security_group.external_alb_sg.id
#   ip_protocol       = "tcp"
#   from_port         = 443
#   to_port           = 443
#   cidr_ipv4         = "0.0.0.0/0"
#   description       = "Allow HTTPS traffic from anywhere"
#   depends_on        = [aws_security_group.external_alb_sg]
# }

# resource "aws_vpc_security_group_egress_rule" "external_alb_sg_egress_rule" {
#   security_group_id = aws_security_group.external_alb_sg.id
#   cidr_ipv4         = "0.0.0.0/0"
#   description       = "Allow all outbound traffic"
#   ip_protocol       = "-1"
# }



# resource "aws_security_group" "uat_server_sg" {
#   name = "${var.resource_name_prefix}-sg-uat-servers"

#   vpc_id = var.vpc_id
#   tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-uat-servers" })

# }

# resource "aws_vpc_security_group_ingress_rule" "uat_server_sg_http_rule" {
#   security_group_id            = aws_security_group.uat_server_sg.id
#   ip_protocol                  = "tcp"
#   from_port                    = 80
#   to_port                      = 80
#   referenced_security_group_id = aws_security_group.external_alb_sg.id
#   description                  = "Allow HTTP traffic from external ALB"
#   depends_on                   = [aws_security_group.uat_server_sg]
# }

# resource "aws_vpc_security_group_egress_rule" "uat_server_sg_egress_rule" {
#   security_group_id = aws_security_group.uat_server_sg.id
#   cidr_ipv4         = "0.0.0.0/0"
#   description       = "Allow all outbound traffic"
#   ip_protocol       = "-1"
# }

# resource "aws_security_group" "all_in_one_server_sg" {
#   name = "${var.resource_name_prefix}-sg-all-in-one-servers"

#   vpc_id = var.vpc_id
#   tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-all-in-one-servers" })

# }

# resource "aws_vpc_security_group_ingress_rule" "all_in_one_server_sg_http_rule" {
#   security_group_id            = aws_security_group.all_in_one_server_sg.id
#   ip_protocol                  = "tcp"
#   from_port                    = 80
#   to_port                      = 80
#   referenced_security_group_id = aws_security_group.external_alb_sg.id
#   description                  = "Allow HTTP traffic from external ALB"
#   depends_on                   = [aws_security_group.all_in_one_server_sg]
# }

# resource "aws_vpc_security_group_egress_rule" "all_in_one_server_sg_egress_rule" {
#   security_group_id = aws_security_group.all_in_one_server_sg.id
#   cidr_ipv4         = "0.0.0.0/0"
#   description       = "Allow all outbound traffic"
#   ip_protocol       = "-1"
# }

# resource "aws_security_group" "interface_endpoint_sg" {
#   name = "${var.resource_name_prefix}-sg-interface-endpoint"

#   vpc_id = var.vpc_id
#   tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-sg-interface-endpoint" })

# }

# resource "aws_vpc_security_group_ingress_rule" "interface_endpoint_sg_https_from_uat_server_sg_rule" {
#   security_group_id            = aws_security_group.interface_endpoint_sg.id
#   ip_protocol                  = "tcp"
#   from_port                    = 443
#   to_port                      = 443
#   referenced_security_group_id = aws_security_group.uat_server_sg.id
#   description                  = "Allow HTTPS traffic from uat servers"
#   depends_on                   = [aws_security_group.uat_server_sg]
# }

# # resource "aws_vpc_security_group_ingress_rule" "interface_endpoint_sg_https_from_all_in_one_server_sg_rule" {
# #   security_group_id            = aws_security_group.interface_endpoint_sg.id
# #   ip_protocol                  = "tcp"
# #   from_port                    = 443
# #   to_port                      = 443
# #   referenced_security_group_id = aws_security_group.all_in_one_server_sg.id
# #   description                  = "Allow HTTPS traffic from all in one servers"
# #   depends_on                   = [aws_security_group.all_in_one_server_sg]
# # }

# resource "aws_vpc_security_group_egress_rule" "interface_endpoint_sg_egress_rule" {
#   security_group_id = aws_security_group.interface_endpoint_sg.id
#   cidr_ipv4         = "0.0.0.0/0"
#   description       = "Allow all outbound traffic"
#   ip_protocol       = "-1"
# }

