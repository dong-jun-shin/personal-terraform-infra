resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.vpc_name}-public-${count.index}"
  }
}

resource "aws_subnet" "private" {
  count      = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  tags = {
    Name = "${var.vpc_name}-private-${count.index}"
  }
}

# Internet Gateway for public subnet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# NAT Instance for private subnet
resource "aws_instance" "nat_instance" {
  ami                    = "ami-01ad0c7a4930f0e43"
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.nat_instance.id]
  key_name               = var.keypair_name

  associate_public_ip_address = true
  source_dest_check          = false

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-nat-instance"
      Role        = "nat"
    }
  )

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }
} 

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id = aws_instance.nat_instance.primary_network_interface_id
  }

  tags = {
    Name = "${var.vpc_name}-private-rt"
  }
}


resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# NAT Instance(EC2 t3.micro + Spot Instance)로 대신 구성하기
# resource "aws_nat_gateway" "main" {
#   allocation_id = aws_eip.nat.id
#   subnet_id     = element(aws_subnet.public.*.id, 0)

#   tags = {
#     Name = "${var.vpc_name}-nat"
#   }
# }

# resource "aws_eip" "nat" {
#   domain = "vpc"
# }

# Security Group
resource "aws_security_group" "nat_instance" {
  name        = "${var.environment}-nat-instance-sg"
  description = "Security group for NAT instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH access"
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.private_subnet_cidrs
    description = "Allow all traffic from private subnets"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-nat-instance-sg"
    }
  )
}

resource "aws_security_group" "app" {
  name        = "${var.vpc_name}-app-sg"
  description = "Security group for application servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.nat_instance.id]
    description = "Allow SSH access"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.nat_instance.id]
    description = "Allow HTTP access"
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.nat_instance.id]
    description = "Allow SSH access"
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.nat_instance.id]
    description = "Allow HTTP outbound traffic"
  } 

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS outbound traffic"
  }
  
  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.private_subnet_cidrs
    description = "Allow PostgreSQL outbound traffic to DB"
  }

  egress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow ICMP outbound traffic for ping"
  }

  tags = {
    Name        = "${var.vpc_name}-app-sg"
  }
}

resource "aws_security_group" "db" {
  name        = "${var.vpc_name}-db-sg"
  description = "Security group for database servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = [aws_security_group.app.id, aws_security_group.nat_instance.id]
    description = "Allow PostgreSQL access from SG"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  
  tags = {
    Name = "${var.vpc_name}-db-sg"
  }
}
