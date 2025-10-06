#VPC

resource "aws_vpc" "main_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(var.tags, { Name = "${var.resource_name_prefix}-vpc" })
}


#Subnet

resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.public_subnet_a_cidr
  availability_zone = var.availability_zones[0]
  tags              = merge(var.tags, { Name = "${var.resource_name_prefix}-public-subnet-a" })
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.public_subnet_b_cidr
  availability_zone = var.availability_zones[1]
  tags              = merge(var.tags, { Name = "${var.resource_name_prefix}-public-subnet-b" })
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnet_a_cidr
  availability_zone = var.availability_zones[0]
  tags              = merge(var.tags, { Name = "${var.resource_name_prefix}-private-subnet-a" })
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnet_b_cidr
  availability_zone = var.availability_zones[1]
  tags              = merge(var.tags, { Name = "${var.resource_name_prefix}-private-subnet-b" })
}

resource "aws_subnet" "private_tgw_subnet_a" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_tgw_subnet_a_cidr
  availability_zone = var.availability_zones[0]
  tags              = merge(var.tags, { Name = "${var.resource_name_prefix}-private-tgw-subnet-a" })
}

resource "aws_subnet" "private_tgw_subnet_b" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_tgw_subnet_b_cidr
  availability_zone = var.availability_zones[1]
  tags              = merge(var.tags, { Name = "${var.resource_name_prefix}-private-tgw-subnet-b" })
}

#eip for nat
resource "aws_eip" "nat_eip" {
  domain = "vpc"
  tags   = merge(var.tags, { Name = "${var.resource_name_prefix}-nat-eip-temp" })
}

#igw
resource "aws_internet_gateway" "igw" {
  vpc_id     = aws_vpc.main_vpc.id
  tags       = merge(var.tags, { Name = "${var.resource_name_prefix}-igw" })
  depends_on = [aws_vpc.main_vpc]
}

#nat #TODO: This nat is for temporary testing only will be removed once centralized networking is implemented
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_a.id
  tags          = merge(var.tags, { Name = "${var.resource_name_prefix}-nat-temp" })
  depends_on    = [aws_internet_gateway.igw]
}

#eip


#route tables
#public routes
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(var.tags, { Name = "${var.resource_name_prefix}-public-route-table" })
}

resource "aws_route_table_association" "public_route_association" {
  for_each = {
    public_a = aws_subnet.public_subnet_a.id
    public_b = aws_subnet.public_subnet_b.id
  }
  subnet_id      = each.value
  route_table_id = aws_route_table.public_route_table.id
}

#private routes

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }
  #TODO: Add 0.0.0.0 to attachment after testing is done
  #   route {
  #     cidr_block = "0.0.0.0/0"
  #     transit_gateway_id = data.aws_ec2_transit_gateway.shared-tgw.id
  #   }
  tags = merge(var.tags, { Name = "${var.resource_name_prefix}-private-route-table" })
}

resource "aws_route_table_association" "private_route_association" {
  for_each = {
    private_a = aws_subnet.private_subnet_a.id
    private_b = aws_subnet.private_subnet_b.id
    tgw_a     = aws_subnet.private_tgw_subnet_a.id
    tgw_b     = aws_subnet.private_tgw_subnet_b.id
  }
  subnet_id      = each.value
  route_table_id = aws_route_table.private_route_table.id
}



#tgw attachment

data "aws_ec2_transit_gateway" "shared-tgw" {
  id = var.tgw_id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment_ab" {
  subnet_ids         = [aws_subnet.private_tgw_subnet_a.id, aws_subnet.private_tgw_subnet_b.id]
  transit_gateway_id = data.aws_ec2_transit_gateway.shared-tgw.id
  vpc_id             = aws_vpc.main_vpc.id
  tags               = merge(var.tags, { Name = "${var.resource_name_prefix}-tgwa-ab" })
}

#TODO: NACL please refer to master list
#NACL

# NACL itself
resource "aws_network_acl" "main_nacl" {
  vpc_id = aws_vpc.main_vpc.id

  tags = merge(var.tags, {
    Name = "${var.resource_name_prefix}-main-nacl"
  })
}

resource "aws_network_acl_association" "main_nacl_association" {
  for_each = {
    public_a  = aws_subnet.public_subnet_a.id
    public_b  = aws_subnet.public_subnet_b.id
    private_a = aws_subnet.private_subnet_a.id
  }
  subnet_id      = each.value
  network_acl_id = aws_network_acl.main_nacl.id

}

# -------------------
# Ingress Rules
# -------------------

resource "aws_network_acl_rule" "ingress_101" {
  network_acl_id = aws_network_acl.main_nacl.id
  rule_number    = 101
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 3388
}

resource "aws_network_acl_rule" "ingress_102" {
  network_acl_id = aws_network_acl.main_nacl.id
  rule_number    = 102
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 3390
  to_port        = 65535
}

resource "aws_network_acl_rule" "ingress_103" {
  network_acl_id = aws_network_acl.main_nacl.id
  rule_number    = 103
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "ingress_104" {
  network_acl_id = aws_network_acl.main_nacl.id
  rule_number    = 104
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "ingress_400" {
  network_acl_id = aws_network_acl.main_nacl.id
  rule_number    = 400
  egress         = false
  protocol       = "-1" # all
  rule_action    = "allow"
  cidr_block     = "10.0.0.0/8"
}

resource "aws_network_acl_rule" "ingress_500" {
  network_acl_id = aws_network_acl.main_nacl.id
  rule_number    = 500
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "172.16.0.0/12"
}

resource "aws_network_acl_rule" "ingress_600" {
  network_acl_id = aws_network_acl.main_nacl.id
  rule_number    = 600
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "192.168.0.0/16"
}

# -------------------
# Egress Rules
# -------------------

resource "aws_network_acl_rule" "egress_101" {
  network_acl_id = aws_network_acl.main_nacl.id
  rule_number    = 101
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "egress_102" {
  network_acl_id = aws_network_acl.main_nacl.id
  rule_number    = 102
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "egress_103" {
  network_acl_id = aws_network_acl.main_nacl.id
  rule_number    = 103
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

resource "aws_network_acl_rule" "egress_104" {
  network_acl_id = aws_network_acl.main_nacl.id
  rule_number    = 104
  egress         = true
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 53
  to_port        = 53
}

resource "aws_network_acl_rule" "egress_105" {
  network_acl_id = aws_network_acl.main_nacl.id
  rule_number    = 105
  egress         = true
  protocol       = "udp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 53
  to_port        = 53
}

resource "aws_network_acl_rule" "egress_106" {
  network_acl_id = aws_network_acl.main_nacl.id
  rule_number    = 106
  egress         = true
  protocol       = "icmp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  icmp_type      = -1
  icmp_code      = -1
}

resource "aws_network_acl_rule" "egress_400" {
  network_acl_id = aws_network_acl.main_nacl.id
  rule_number    = 400
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "10.0.0.0/8"
}

resource "aws_network_acl_rule" "egress_500" {
  network_acl_id = aws_network_acl.main_nacl.id
  rule_number    = 500
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "172.16.0.0/12"
}

resource "aws_network_acl_rule" "egress_600" {
  network_acl_id = aws_network_acl.main_nacl.id
  rule_number    = 600
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "192.168.0.0/16"
}

