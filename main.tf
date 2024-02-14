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
  ingress {
    from_port   = var.backend_ingrss
    to_port     = var.backend_ingrss
    protocol    = "tcp"
    cidr_blocks = [var.backend_cider]
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

}

# provisioner "remote-exec" {
#   connection {
#     type        = "ssh"
#     user        = "ubuntu" # Verify this user exists
#     private_key = file(local_file.frontend_private_key.filename)
#     host        = self.public_ip
#     # Consider more specific SSH arguments like:
#     # ssh_args    = ["-o StrictHostKeyChecking=no"]
#   }
#   inline = [
#     "sudo apt update -y",
#     "sudo apt-get install -y docker.io",
#   ]
# }


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
#       


#     ]
#   }
# }

