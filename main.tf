terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Security Group
resource "aws_security_group" "ssh" {
  name = "security-group-for-ssh"

  ingress {
    description = "SSH ingress"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Key Pair
resource "aws_key_pair" "server_key" {
  key_name   = "server"
  public_key = file("/home/davidubuntu/Desktop/codeplay/server1.pub")
}

# EC2 Instance
resource "aws_instance" "server1" {
  ami                    = "ami-0fa3fe0fa7920f68e"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.ssh.id]
  key_name               = aws_key_pair.server_key.key_name

  # --- FILE PROVISIONER ---
  #   provisioner "file" {
  #     source      = "/home/davidubuntu/Desktop/codeplay/instal_docker.sh"
  #     destination = "/tmp/install_docker.sh"
  #     when = create

  #     connection {
  #       type        = "ssh"
  #       user        = "ec2-user"
  #       private_key = file(./server1")  
  #       host        = self.public_ip
  #     }
  #   }


  provisioner "remote-exec" {
    script = "/home/davidubuntu/Desktop/codeplay/install_docker.sh"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("./server1")
      host        = self.public_ip
    }
  }
}

output "ip_address" {
  value = aws_instance.server1.public_ip
}
