resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "my_public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-1a"
  tags = {
    "Name" = "Dev-public"
  }

}

resource "aws_internet_gateway" "my_internet_gateway" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = "igw"
  }

}

resource "aws_route_table" "myroute" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "myroute-table"
  }
}

resource "aws_route" "default_route" {
  route_table_id = aws_route_table.myroute.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.my_internet_gateway.id
}