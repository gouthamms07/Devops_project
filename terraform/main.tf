provider "aws" {
  region = "ap-south-1"
}

# -------------------------
# VARIABLES
# -------------------------
variable "key_name" {
  description = "Existing AWS EC2 key pair name"
  type        = string
  default     = "k8s-key"
}

# -------------------------
# VPC
# -------------------------
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}

# -------------------------
# SECURITY GROUP
# -------------------------
resource "aws_security_group" "k8s_sg" {
  vpc_id = aws_vpc.main.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubernetes API
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # NodePort
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Internal Kubernetes communication
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# -------------------------
# MASTER NODE
# -------------------------
resource "aws_instance" "master" {
  ami                    = "ami-05d2d839d4f73aafb"
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  key_name               = var.key_name

  tags = {
    Name = "k8s-master"
  }
}

# -------------------------
# WORKER NODE
# -------------------------
resource "aws_instance" "worker" {
  ami                    = "ami-05d2d839d4f73aafb"
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  key_name               = var.key_name

  tags = {
    Name = "k8s-worker"
  }
}

# -------------------------
# OUTPUTS
# -------------------------
output "master_ip" {
  value = aws_instance.master.public_ip
}

output "worker_ip" {
  value = aws_instance.worker.public_ip
}
