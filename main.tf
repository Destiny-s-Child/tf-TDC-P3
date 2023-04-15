terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.62.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Create vpc; CIDR 10.0.0.0/16
resource "aws_vpc" "main" {
  cidr_block                       = var.vpc_cidr
  assign_generated_ipv6_cidr_block = false
  enable_dns_hostnames             = true
  enable_dns_support               = true
  tags = {
    "Name" = "${var.default_tags.env}-VPC"
  }
}
# Public Subnet (1) 10.0.0.0/24 , (2) 10.0.1.0/24
resource "aws_subnet" "Public" {
  count                   = var.public_subnet_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  tags = {
    "Name" = "${var.default_tags.env}-PUB-SUB-${data.aws_availability_zones.availability_zone.names[count.index]}"
  }
  availability_zone = data.aws_availability_zones.availability_zone.names[count.index]
}
# Private Subnet (1) 10.0.2.0/24, (2) 10.0.3.0/24
resource "aws_subnet" "Private" {
  count      = var.private_subnet_count
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + var.public_subnet_count)
  tags = {
    "Name" = "${var.default_tags.env}-PRIV-SUB-${data.aws_availability_zones.availability_zone.names[count.index]}"
  }
  availability_zone = data.aws_availability_zones.availability_zone.names[count.index]
}
# IGW 
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id #Attachment
  tags = {
    "Name" = "${var.default_tags.env}-IGW"
  }
}
# EIP
resource "aws_eip" "NAT_EIP" {
  vpc = true
  tags = {
    "Name" = "${var.default_tags.env}-EIP"
  }
}
# NGW
resource "aws_nat_gateway" "main_NAT" {
  allocation_id = aws_eip.NAT_EIP.id 
  subnet_id = aws_subnet.Public.0.id 
  tags = {
    "Name" = "${var.default_tags.env}-NGW"
  }
}
# Public Route Table 
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id 
  tags = {
    "Name" = "${var.default_tags.env}-PUB-RT"
  }
}
# Public Routes - For Route Table
resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main_igw.id
}
# Public Route Table Association
resource "aws_route_table_association" "public" {
  count = var.public_subnet_count
  subnet_id = element(aws_subnet.Public.*.id, count.index)
  route_table_id = aws_route_table.public.id 
}
# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    "name" = "${var.default_tags.env}-PRIV-RT"
  }
}
# Private Routes - For Private Route Table
resource "aws_route" "private" {
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main_NAT.id
}
# Private Route Table Association
resource "aws_route_table_association" "private" {
  count = var.private_subnet_count
  subnet_id = element(aws_subnet.Private.*.id, count.index)
  route_table_id = aws_route_table.private.id 
}