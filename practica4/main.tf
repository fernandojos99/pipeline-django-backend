terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

resource "aws_vpc" "vpc_terraform" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc_terraform"
  }
}




resource "aws_subnet" "subnet_terraform" {
  vpc_id            = aws_vpc.vpc_terraform.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet_terraform"
  }
}


# Nueva subred para que funcione el ALB 
resource "aws_subnet" "subnet_terraform2" {
  vpc_id            = aws_vpc.vpc_terraform.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet_terraform2"
  }
}




resource "aws_internet_gateway" "igw_terraform" {
  vpc_id = aws_vpc.vpc_terraform.id

  tags = {
    Name = "igw_terraform"
  }
}

resource "aws_route_table" "route_table_terraform" {
  vpc_id = aws_vpc.vpc_terraform.id

  tags = {
    Name = "route_table_terraform"
  }
}



# Para la subnet2
# Se comento porque solo es una igw por vpc
# resource "aws_internet_gateway" "igw_terraform2" {
#   vpc_id = aws_vpc.vpc_terraform.id

#   tags = {
#     Name = "igw_terraform2"
#   }
# }
# resource "aws_route_table" "route_table_terraform2" {
#   vpc_id = aws_vpc.vpc_terraform.id

#   tags = {
#     Name = "route_table_terraform2"
#   }
# }






resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.route_table_terraform.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw_terraform.id
}

resource "aws_route_table_association" "subnet_assoc" {
  subnet_id      = aws_subnet.subnet_terraform.id
  route_table_id = aws_route_table.route_table_terraform.id
}


# # Para la subnet2
# resource "aws_route" "default_route2" {
#   route_table_id         = aws_route_table.route_table_terraform2.id
#   destination_cidr_block = "0.0.0.0/0"
#   gateway_id             = aws_internet_gateway.igw_terraform2.id
# }

# Asociar al subnet a la misma tabla de rutas.
resource "aws_route_table_association" "subnet_assoc2" {
  subnet_id      = aws_subnet.subnet_terraform2.id
  route_table_id = aws_route_table.route_table_terraform.id
}



output "vpc_id" {
  value = aws_vpc.vpc_terraform.id
}

output "subnet_id" {
  value = aws_subnet.subnet_terraform.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw_terraform.id
}

output "route_table_id" {
  value = aws_route_table.route_table_terraform.id
}




