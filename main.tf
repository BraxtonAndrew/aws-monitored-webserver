terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 5.0"
        }
    }
}

provider "aws" {
    region = "us-east-1"
}

##################### Network resources ######################
resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"

    tags = {
        Name = "monitored-webserver-vpc"
    }
}

resource "aws_subnet" "public" {
    vpc_id            = aws_vpc.main.id
    cidr_block        = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true

    tags = {
        Name = "monitored-webserver-public-subnet"
    }
}

resource "aws_internet_gateway" "main" {
    # Allows the VPC to connect to the internet
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "monitored-webserver-igw"
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route {
        # Any traffic not headed to 10.0.0.0/16 should go out through the IGW
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }

    tags = {
        Name = "monitored-webserver-public-rt"
    }
}

resource "aws_route_table_association" "public" {
    # Connects the public subnet to the public route table
    subnet_id      = aws_subnet.public.id
    route_table_id = aws_route_table.public.id
}
