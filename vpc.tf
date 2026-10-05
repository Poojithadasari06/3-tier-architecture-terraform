#Vpc craetion for project

resource "aws_vpc" "Project3" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "Project-VPC"
  }
}

#Public subnet 1 creation

resource "aws_subnet" "Public-subnet-1" {
  vpc_id            = aws_vpc.Project3.id
  availability_zone = "ap-southeast-2a"
  cidr_block        = "10.0.0.0/24"
  tags = {
    Name = "Public-Web-subnet-1"
  }
}

#Public subnet 2 creation

resource "aws_subnet" "Public-subnet-2" {
  vpc_id            = aws_vpc.Project3.id
  availability_zone = "ap-southeast-2b"
  cidr_block        = "10.0.5.0/24"
  tags = {
    Name = "Public-Web-subnet-2"
  }
}

#private subnet1 for APP

resource "aws_subnet" "Private-subnet-app-1" {
  vpc_id            = aws_vpc.Project3.id
  availability_zone = "ap-southeast-2a"
  cidr_block        = "10.0.10.0/24"
  tags = {
    Name = "Private-App-subnet-1"
  }
}

#private subnet2 for APP

resource "aws_subnet" "Private-subnet-app-2" {
  vpc_id            = aws_vpc.Project3.id
  availability_zone = "ap-southeast-2b"
  cidr_block        = "10.0.15.0/24"
  tags = {
    Name = "Private-App-subnet-2"
  }
}

#private subnet1 for DB

resource "aws_subnet" "Private-subnet-DB-1" {
  vpc_id            = aws_vpc.Project3.id
  availability_zone = "ap-southeast-2a"
  cidr_block        = "10.0.20.0/24"
  tags = {
    Name = "Private-DB-subnet-1"
  }
}

#private subnet2 for DB

resource "aws_subnet" "Private-subnet-DB-2" {
  vpc_id            = aws_vpc.Project3.id
  availability_zone = "ap-southeast-2b"
  cidr_block        = "10.0.25.0/24"
  tags = {
    Name = "Private-DB-subnet-2"
  }
}

#Internet gateway creation

resource "aws_internet_gateway" "Project_IGW" {
  vpc_id = aws_vpc.Project3.id
  tags = {
    Name = "3-tier-IGW"
  }
}

#Public route table

resource "aws_route_table" "Public-Route-Table" {
  vpc_id = aws_vpc.Project3.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Project_IGW.id
  }
  tags = {
    Name = "Project-Public-rt"
  }
}

#Public subnet associations

resource "aws_route_table_association" "Public-subnet-association1" {
  subnet_id      = aws_subnet.Public-subnet-1.id
  route_table_id = aws_route_table.Public-Route-Table.id
}
resource "aws_route_table_association" "Public-subnet-association2" {
  subnet_id      = aws_subnet.Public-subnet-2.id
  route_table_id = aws_route_table.Public-Route-Table.id

}

#private route table

resource "aws_route_table" "Private-Route-Table" {
  vpc_id = aws_vpc.Project3.id
  route {
    cidr_block = "0.0.0.0/0"
    #nat gateway association
    nat_gateway_id = aws_nat_gateway.Project-NAT.id
  }
  tags = {
    Name = "Project-Private-rt"
  }
}

#private subnet associations

resource "aws_route_table_association" "Private-subnet-association1" {
  for_each = {
    "Private-subnet-app-1" = aws_subnet.Private-subnet-app-1.id
    "Private-subnet-app-2" = aws_subnet.Private-subnet-app-2.id
    "Private-subnet-DB-1"  = aws_subnet.Private-subnet-DB-1.id
    "Private-subnet-DB-2"  = aws_subnet.Private-subnet-DB-2.id
  }
  subnet_id      = each.value
  route_table_id = aws_route_table.Private-Route-Table.id
}
# elastic IP creation
resource "aws_eip" "NAT-elastic-IP" {
  domain = "vpc"
  tags = {
    Name = "Elastic-IP-NAT"
  }
}
#NAT gateway for private rt
resource "aws_nat_gateway" "Project-NAT" {
  allocation_id = aws_eip.NAT-elastic-IP.id
  subnet_id     = aws_subnet.Public-subnet-1.id
  tags = {
    Name = "NAT-Public"
  }
  depends_on = [aws_internet_gateway.Project_IGW]
}
