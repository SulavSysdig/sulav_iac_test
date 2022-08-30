locals {
  newbits = 2
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = cidrsubnet(aws_vpc.default.cidr_block, local.newbits, 0)
  availability_zone       = local.zone
  map_public_ip_on_launch = true
  tags = {
    Name      = "${var.name}-public-subnet"
    CreatedBy = "terraform-demoenv-${var.name}"
  }
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id
  tags = {
    Name      = "${var.name}-public-rt"
    CreatedBy = "terraform-demoenv-${var.name}"
  }
}

resource "aws_route" "internet_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.default.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id

  lifecycle {
    ignore_changes        = [subnet_id, route_table_id]
    create_before_destroy = true
  }
}

resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public.id

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [subnet_id]
  }

  tags = {
    Name      = "${var.name}-nat-gw"
    CreatedBy = "terraform-demoenv-${var.name}"
  }
}

resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.default.id
  cidr_block              = cidrsubnet(aws_vpc.default.cidr_block, local.newbits, 1)
  availability_zone       = local.zone
  map_public_ip_on_launch = false
  tags = {
    Name      = "${var.name}-private-subnet"
    CreatedBy = "terraform-demoenv-${var.name}"
  }
  depends_on = [aws_nat_gateway.nat_gw]
  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.default.id
  tags = {
    Name      = "${var.name}-private-rt"
    CreatedBy = "terraform-demoenv-${var.name}"
  }
}

resource "aws_route" "nat_route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [route_table_id, nat_gateway_id]
  }

  depends_on = [aws_nat_gateway.nat_gw]
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id

  lifecycle {
    ignore_changes        = [subnet_id]
    create_before_destroy = true
  }
}

resource "aws_security_group" "default" {
  name        = "internal"
  description = "Default security group that allows inbound and outbound traffic from all instances in the VPC"
  vpc_id      = aws_vpc.default.id
  tags = {
    Name      = "${var.name}-sg-default"
    CreatedBy = "terraform-demoenv-${var.name}"
  }
}

resource "aws_security_group_rule" "internal_ingress" {
  type              = "ingress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.default.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "internal_egress" {
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  self              = true
  security_group_id = aws_security_group.default.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "nat" {
  name        = "nat"
  description = "security group that allows all inbound and outbound traffic. should only be applied to instances in a private subnet"
  vpc_id      = aws_vpc.default.id
  tags = {
    Name      = "${var.name}-sg-nat"
    CreatedBy = "terraform-demoenv-${var.name}"
  }
  depends_on = [aws_nat_gateway.nat_gw]
}

resource "aws_security_group_rule" "nat_ingress" {
  type              = "ingress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nat.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "nat_egress" {
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nat.id

  lifecycle {
    create_before_destroy = true
  }
}
