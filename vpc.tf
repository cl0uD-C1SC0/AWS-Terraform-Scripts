# Creating a Simple VPC

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    "Name" = "VPC-TF"
  }

  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
}

# Creataing a TWO Public Subnets and TWO Private Subnets

resource "aws_subnet" "public-subnet-01" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "TF-PublicSubnet-1A"
  }
}

resource "aws_subnet" "public-subnet-02" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "TF-PublicSubnet-1B"
  }
}

resource "aws_subnet" "private-subnet-01" {
    vpc_id              = aws_vpc.main.id
    cidr_block          = "10.0.2.0/24"
    availability_zone   = "us-east-1a"

    tags = {
        Name = "TF-PrivateSubnet-1A"
  }
}

resource "aws_subnet" "private-subnet-02" {
    vpc_id              = aws_vpc.main.id
    cidr_block          = "10.0.3.0/24"
    availability_zone   = "us-east-1b"

    tags = {
        Name = "TF-PrivateSUbnet-1B"
  }
}

# Creating a Internet Gateway

resource "aws_internet_gateway" "internet-gateway" {
    vpc_id      = aws_vpc.main.id

    tags = {
        Name = "TF-InternetGateway"
  }

  depends_on = [aws_vpc.main]
}

# Creating a NAT Gateway

resource "aws_nat_gateway" "nat-gateway" {
    allocation_id = aws_eip.eip.id
    subnet_id  = aws_subnet.public-subnet-01.id

    depends_on = [aws_internet_gateway.internet-gateway, aws_vpc.main, aws_subnet.public-subnet-01, aws_eip.eip]
}

# Creating Public Route Table and Associations

resource "aws_route_table" "TF-PublicRouteTable" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internet-gateway.id
  }
  
    tags = {
        Name = "TF-PublicRouteTable"
  }

    depends_on = [aws_internet_gateway.internet-gateway]
}

resource "aws_route_table_association" "association-1a-public" {
    subnet_id       = aws_subnet.public-subnet-01.id
    route_table_id  = aws_route_table.TF-PublicRouteTable.id

    depends_on = [aws_subnet.public-subnet-01, aws_route_table.TF-PublicRouteTable, aws_internet_gateway.internet-gateway]
}

resource "aws_route_table_association" "association-1b-public" {
    subnet_id       = aws_subnet.public-subnet-02.id
    route_table_id  = aws_route_table.TF-PublicRouteTable.id

    depends_on = [aws_subnet.public-subnet-02, aws_route_table.TF-PublicRouteTable, aws_internet_gateway.internet-gateway]
}

# Creating a Private Route Table and Associations, and EIP

resource "aws_eip" "eip" {
    depends_on = [aws_vpc.main, aws_internet_gateway.internet-gateway]
}

resource "aws_route_table" "PrivateRouteTable" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.nat-gateway.id
  }

    tags = {
        Name = "TF-PrivateRouteTable"
  }

    depends_on = [aws_nat_gateway.nat-gateway, aws_internet_gateway.internet-gateway]
}

resource "aws_route_table_association" "association-1a-private" {
    subnet_id       = aws_subnet.private-subnet-01.id
    route_table_id  = aws_route_table.PrivateRouteTable.id

    depends_on = [aws_subnet.private-subnet-01, aws_route_table.PrivateRouteTable, aws_internet_gateway.internet-gateway]
}

resource "aws_route_table_association" "association-1b-private" {
    subnet_id       = aws_subnet.private-subnet-02.id
    route_table_id  = aws_route_table.PrivateRouteTable.id

    depends_on = [aws_subnet.private-subnet-02, aws_route_table.PrivateRouteTable, aws_internet_gateway.internet-gateway]
}