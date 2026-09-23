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

############### Security ######################
resource "aws_security_group" "web" {
    name = "monitored-webserver-sg"
    description = "Allow HTTP and SSH traffic"
    vpc_id = aws_vpc.main.id

    ingress {
        description = "Allow HTTP"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "Allow SSH"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "Allow all outbound traffic"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "monitored-webserver-sg"
    }
}

########### Compute resources ######################
resource "aws_instance" "web" {
    ami = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI (HVM), SSD Volume Type
    instance_type = "t3.micro"
    subnet_id = aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.web.id]

    tags = {
        Name = "monitored-webserver-instance"
    }
}