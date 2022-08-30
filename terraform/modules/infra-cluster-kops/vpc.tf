resource "aws_vpc" "default" {
  cidr_block           = "172.20.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name      = "${var.name}-vpc"
    CreatedBy = "terraform-demoenv-${var.name}"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
  tags = {
    Name      = "${var.name}-ig"
    CreatedBy = "erraform-demoenv-${var.name}"
  }
}
