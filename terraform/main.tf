terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket       = "cs312-puckette-backups"
    key          = "CS312/cs312-key"
    region       = "us-east-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = "us-east-1"
  # If you configured a named profile above, add: profile = "cs312"
}

# Use the default VPC instead of creating a new one
data "aws_vpc" "default" {
  default = true
}

# Security Group for the control node: SSH access from your laptop
resource "aws_security_group" "control" {
  name        = "cs312-tf-control-sg"
  description = "Control node: SSH only"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cs312-tf-control-sg"
  }
}

# Security Group for the managed node: SSH from control node only, HTTP from anywhere
resource "aws_security_group" "managed" {
  name        = "cs312-tf-managed-sg"
  description = "Managed node: SSH from control node, HTTP from anywhere"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description     = "SSH from control node"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.control.id]
  }

  ingress {
    description = "HTTP"
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cs312-tf-managed-sg"
  }
}

# Control node: you SSH into this instance from your laptop
resource "aws_instance" "control" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.control.id]
  iam_instance_profile   = "LabInstanceProfile"

  tags = {
    Name = "cs312-tf-control"
  }
}

# Managed node: the server that will run the application
resource "aws_instance" "managed" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.managed.id]
  iam_instance_profile   = "LabInstanceProfile"

  tags = {
    Name = "cs312-tf-managed"
  }
}

# ECR repository for the CI/CD pipeline
resource "aws_ecr_repository" "minecraft" {
  name                 = "cs312-minecraft-server"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}
