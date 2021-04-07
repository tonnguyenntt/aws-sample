///////////////////////////////////////// VPC //////////////////////////////////////////
// Create VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true

  tags =  {
    Name = "ton-vpc"
  }
}
////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////// Public subnet //////////////////////////////////////
// Create Internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags =  {
    Name = "internet-gateway"
  }
}

// Create Public subnet
resource "aws_subnet" "subnet_public" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.subnet_cidr_public
  availability_zone = var.aws_availability_zone

  tags =  {
    Name = "subnet-public"
  }
}

// Create Route table for Public subnet
resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
  }

  tags =  {
      Name = "rtb-public"
  }
}

// Associate above Route table & Public subnet
resource "aws_route_table_association" "routing_public" {
    subnet_id = aws_subnet.subnet_public.id
    route_table_id = aws_route_table.rtb_public.id
}
////////////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////// Public/NAT instance ////////////////////////////////
// Preare Security group
resource "aws_security_group" "sg_public" {
  name = "sg_public"
  description = "Security group for Public/NAT instance"
  vpc_id = aws_vpc.vpc.id

  // Pass through the traffic from Private subnet to Internet (HTTP/HTTPS)
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [var.subnet_cidr_private]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = [var.subnet_cidr_private]
  }
  // Allow incoming access from public Internet (SSH, HTTP/HTTPS, MySQL, ICMP)
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // Allow outgoing access to public Internet (HTTP/HTTPS, ICMP)
  egress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  // Allow outgoing access to whole VPC (SSH)
  egress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "sg-public"
  }
}

// Create Public/NAT instance
resource "aws_instance" "instance_public" {
  ami = var.aws_ami
  availability_zone = var.aws_availability_zone
  instance_type = var.aws_instance_type
  vpc_security_group_ids = [aws_security_group.sg_public.id]
  subnet_id = aws_subnet.subnet_public.id
  associate_public_ip_address = true
  source_dest_check = false
  key_name = aws_key_pair.key_pair.key_name

  tags = {
    Name = "instance-public"
  }
}

// Create Elastic IP & bind it with Public instance
resource "aws_eip" "eip_public" {
  instance = aws_instance.instance_public.id
  vpc = true

  tags = {
    Name = "eip-public"
  }
}
////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////// Private subnet ///////////////////////////////////
// Create Private subnet
resource "aws_subnet" "subnet_private" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.subnet_cidr_private
  availability_zone = var.aws_availability_zone

  tags =  {
    Name = "subnet-private"
  }
}

// Create Route table for Private subnet
resource "aws_route_table" "rtb_private" {
  vpc_id = aws_vpc.vpc.id

  route {
      cidr_block = "0.0.0.0/0"
      instance_id = aws_instance.instance_public.id
  }

  tags =  {
      Name = "rtb-private"
  }
}

// Associate above Route table & Private subnet
resource "aws_route_table_association" "routing_private" {
    subnet_id = aws_subnet.subnet_private.id
    route_table_id = aws_route_table.rtb_private.id
}
////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////// Private instance /////////////////////////////////
// Preare Security group
resource "aws_security_group" "sg_private" {
  name = "sg_private"
  description = "Security group for Private instance"
  vpc_id = aws_vpc.vpc.id

  // Allow incoming access from Public subnet (SSH, ICMP)
  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.subnet_cidr_public]
  }

  // Allow outgoing access to public Internet (HTTP/HTTPS, ICMP)
  egress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-private"
  }
}

// Create Private instance
resource "aws_instance" "instance_private" {
  ami = var.aws_ami
  availability_zone = var.aws_availability_zone
  instance_type = var.aws_instance_type
  vpc_security_group_ids = [aws_security_group.sg_private.id]
  subnet_id = aws_subnet.subnet_private.id
  key_name = aws_key_pair.key_pair.key_name

  tags = {
    Name = "instance-private"
  }
}
////////////////////////////////////////////////////////////////////////////////////////
