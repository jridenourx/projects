# --- FOUNDATION BLOCKS ---

# 1. The VPC (The container for everything else)
resource "aws_vpc" "capstone_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags = {
    Name      = "jjr2606-capstone-vpc"
    Project   = "Cloud-Security-Capstone"
    ManagedBy = "Terraform"
  }
}

# 2. Public Subnet (For NAT/Administrative access)
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.capstone_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name      = "public-subnet-1"
    Project   = "Cloud-Security-Capstone"
    ManagedBy = "Terraform"
  }
}

# 3. Private Subnet (Where the RDS will live)
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.capstone_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name      = "private-subnet-db"
    Project   = "Cloud-Security-Capstone"
    ManagedBy = "Terraform"
  }
}

# 3.1. Second Private Subnet (Required for RDS Multi-AZ Subnet Group)
resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.capstone_vpc.id
  cidr_block        = "10.0.3.0/24"    # Different from 10.0.2.0
  availability_zone = "us-east-1b"      # Different from us-east-1a

  tags = {
    Name      = "private-subnet-db-2"
    Project   = "Cloud-Security-Capstone"
    ManagedBy = "Terraform"
  }
}

# 3.2. Associate Private Subnet 2 with Private Route Table
resource "aws_route_table_association" "private_2_assoc" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_rt.id
}

# 4. Private Route Table (No route to the Internet Gateway)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.capstone_vpc.id

  tags = {
    Name      = "private-route-table"
    Project   = "Cloud-Security-Capstone"
    ManagedBy = "Terraform"
  }
}

# 5. Associate Private Subnet with Private Route Table
resource "aws_route_table_association" "private_1_assoc" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private_rt.id
}

# 6. Internet Gateway (Allows the VPC to talk to the internet)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.capstone_vpc.id

  tags = {
    Name      = "capstone-igw"
    Project   = "Cloud-Security-Capstone"
    ManagedBy = "Terraform"
  }
}

# 7. Public Route Table (The path to the IGW)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.capstone_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name      = "public-route-table"
    Project   = "Cloud-Security-Capstone"
    ManagedBy = "Terraform"
  }
}

# 8. Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public_1_assoc" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}