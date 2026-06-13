# =============================================================================
# main.tf - Infrastructure as Code avec Terraform
# TP DevOps - UCAD Département Informatique 2025-2026
# Déploiement d'une instance EC2 AWS avec Nginx
# =============================================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Stockage du state en remote (recommandé en production)
  # backend "s3" {
  #   bucket = "mon-terraform-state-bucket"
  #   key    = "tp-devops/terraform.tfstate"
  #   region = "us-east-1"
  # }
}

# Configuration du provider AWS
provider "aws" {
  region = var.aws_region
}

# =============================================================================
# Variables
# =============================================================================
variable "aws_region" {
  description = "Région AWS"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
  default     = "t2.micro"
}

variable "project_name" {
  description = "Nom du projet"
  type        = string
  default     = "tp-devops-ucad"
}

# =============================================================================
# Security Group - Règles de pare-feu
# =============================================================================
resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-sg"
  description = "Security group pour le serveur web TP DevOps"

  # Autoriser HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Autoriser HTTPS
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Autoriser SSH (à restreindre en production)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Autoriser le port 3000 (application Node.js)
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Autoriser tout le trafic sortant
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-sg"
    Project = var.project_name
  }
}

# =============================================================================
# Instance EC2
# =============================================================================
resource "aws_instance" "web" {
  ami             = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 (us-east-1)
  instance_type   = var.instance_type
  security_groups = [aws_security_group.web_sg.name]

  tags = {
    Name    = "${var.project_name}-server"
    Project = var.project_name
    Env     = "production"
  }

  # Script d'initialisation automatique (User Data)
  user_data = <<-EOF
    #!/bin/bash
    # Mise à jour du système
    apt-get update -y
    apt-get upgrade -y

    # Installation de Node.js 18
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt-get install -y nodejs

    # Installation de Nginx
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx

    # Installation de PM2 (gestionnaire de processus Node.js)
    npm install -g pm2

    # Cloner et démarrer l'application
    git clone https://github.com/votre-nom/tp-devops-app.git /var/www/app
    cd /var/www/app
    npm install --production
    pm2 start src/app.js --name "tp-devops-app"
    pm2 startup
    pm2 save

    echo "Installation terminée !" >> /var/log/user-data.log
  EOF
}

# =============================================================================
# Outputs
# =============================================================================
output "public_ip" {
  description = "Adresse IP publique du serveur"
  value       = aws_instance.web.public_ip
}

output "public_dns" {
  description = "DNS public du serveur"
  value       = aws_instance.web.public_dns
}

output "instance_id" {
  description = "ID de l'instance EC2"
  value       = aws_instance.web.id
}
