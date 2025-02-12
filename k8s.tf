# Terraform script to provision AWS infrastructure
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "k8s_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "k8s_subnet" {
  vpc_id            = aws_vpc.k8s_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_security_group" "k8s_sg" {
  vpc_id = aws_vpc.k8s_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "k8s_master" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.k8s_subnet.id
  security_groups = [aws_security_group.k8s_sg.name]
  key_name      = "your-key"

  tags = {
    Name = "k8s-master"
  }
}

resource "aws_instance" "k8s_workers" {
  count         = 2
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.k8s_subnet.id
  security_groups = [aws_security_group.k8s_sg.name]
  key_name      = "your-key"

  tags = {
    Name = "k8s-worker-${count.index}"
  }
}

output "master_ip" {
  value = aws_instance.k8s_master.public_ip
}

output "worker_ips" {
  value = aws_instance.k8s_workers[*].public_ip
}

# Generate Ansible inventory file
data "template_file" "ansible_inventory" {
  template = <<EOF
  [masters]
  ${aws_instance.k8s_master.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=your-key.pem

  [workers]
  %{for ip in aws_instance.k8s_workers[*].public_ip} ${ip} ansible_user=ubuntu ansible_ssh_private_key_file=your-key.pem
  %{endfor}
  EOF
}

resource "local_file" "inventory" {
  content  = data.template_file.ansible_inventory.rendered
  filename = "inventory.ini"
}
