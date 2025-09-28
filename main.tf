provider "aws" { region = var.aws_region }

data "aws_vpc" "default" { default = true }

data "aws_subnets" "default" {
  filter { name = "vpc-id" values = [data.aws_vpc.default.id] }
}

resource "tls_private_key" "deployer" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = "clo835-deployer-key"
  public_key = tls_private_key.deployer.public_key_openssh
}

resource "local_file" "private_key_pem" {
  filename = "${path.cwd}/clo835_deployer.pem"
  content  = tls_private_key.deployer.private_key_pem
  file_permission = "0400"
}

resource "aws_ecr_repository" "webapp" { name = "clo835-webapp" }
resource "aws_ecr_repository" "mysql" { name = "clo835-mysql" }

resource "aws_security_group" "ec2_sg" {
  name = "clo835-ec2-sg"
  vpc_id = data.aws_vpc.default.id
  ingress {
    from_port = 22; to_port = 22; protocol = "tcp"; cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 8081; to_port = 8083; protocol = "tcp"; cidr_blocks = ["0.0.0.0/0"]
  }
  egress { from_port = 0; to_port = 0; protocol = "-1"; cidr_blocks = ["0.0.0.0/0"] }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter { name = "name" values = ["amzn2-ami-hvm-*-x86_64-gp2"] }
}

resource "aws_instance" "web" {
  ami = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  subnet_id = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  key_name = aws_key_pair.deployer.key_name
  associate_public_ip_address = true
  user_data = file("${path.module}/user_data.sh")
  tags = { Name = "clo835-ec2" }
}
