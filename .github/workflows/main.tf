provider "aws" {
  region = "us-east-1" 
}

resource "aws_security_group" "Labuba" {
  name        = "allow_web_ssh"
  description = "Allow SSH and HTTP traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "Labuba" {
  ami           = "i-0f0b8f837eac9d107" # AMI для Ubuntu 24.04 в us-east-1
  instance_type = "t3.micro"
  key_name      = "my-aws-key" # НАЗВА ТВОГО КЛЮЧА В AWS (без .pem)

  vpc_security_group_ids = [aws_security_group.lab6_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ubuntu

              # Запуск Watchtower
              sudo docker run -d --name watchtower -v /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower --interval 30

              # Запуск твого застосунку
              sudo docker run -d -p 80:80 --name my-app kornini/lab4:latest
              EOF

  tags = {
    Name = "DockerAppServer"
  }
}

output "instance_ip" {
  value = aws_instance.lab6_server.public_ip
}
