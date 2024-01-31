terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.32.1"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_security_group" "FrontendSG" {
  name = "FrontEndSecurityGroup"

  ingress {
    from_port   = var.http_ingress
    to_port     = var.http_ingress
    protocol    = "tcp"
    cidr_blocks = [var.http_cidr]
  }

  ingress {
    from_port   = var.ssh_ingress
    to_port     = var.ssh_ingress
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    from_port   = var.application_ingress
    to_port     = var.application_ingress
    protocol    = "tcp"
    cidr_blocks = [var.app_cidr]
  }
  ingress {
    from_port   = var.https_ingress
    to_port     = var.https_ingress
    protocol    = "tcp"
    cidr_blocks = [var.https_cder]

  }
}

resource "aws_key_pair" "frontendkey" {
  key_name   = "frontend_key"
  public_key = tls_private_key.frontend_key.public_key_openssh # Reference the correct resource
}

resource "tls_private_key" "frontend_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "frontend_private_key" {
  content  = tls_private_key.frontend_key.private_key_pem
  filename = "frontend_key.pem"
}

locals {
  instances = toset(["frontend", "backend"])
}

resource "aws_instance" "frontend" {
  for_each               = local.instances
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.frontendkey.key_name
  subnet_id              = "subnet-037ad1d149f013016"
  vpc_security_group_ids = [aws_security_group.FrontendSG.id]
  tags = {
    Name = each.key
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(local_file.frontend_private_key.filename)
      host        = self.public_ip
    }

    inline = [
      "sudo apt update -y",
      "sudo apt install -y curl",
      "curl -s https://deb.nodesource.com/setup_18.x | sudo bash",
      "sudo apt install -y nodejs",
      "node --version",
      " git clone https://github.com/shri14/TravelMemoryapp.git",
      "cd TravelMemoriesApp/frontend && sudo npm install",
      "sudo npm start & disown", # Run npm start in the background and disown the process
    ]
  }
}





# resource "aws_instance" "Backend" {
#   ami                    = var.ami
#   instance_type          = var.instance_type
#   key_name               = aws_key_pair.frontendkey.key_name
#   vpc_security_group_ids = [aws_security_group.FrontendSG.id]
#   tags = {
#     Name = "BackendInstance"
#   }
#   provisioner "remote-exec" {
#     connection {
#       type        = "ssh"
#       user        = "ubuntu"
#       private_key = file(local_file.frontend_private_key.filename)
#       host        = self.public_ip
#     }
#     inline = [
#       "sudo apt update -y",
#       "sudo cd /home/ubuntu",
#       "sudo apt install -y curl",
#       "sudo curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -",
#       "sudo apt install nodejs -y",
#       "sudo node --version",
#       "sudo git clone https://github.com/UnpredictablePrashant/TravelMemoriesApp.git",
#       "sudo cd TravelMemoriesApp/backend",
#       "sudo npm install && node index.js",

#     ]
#   }
# }

