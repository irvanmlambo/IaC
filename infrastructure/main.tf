resource "aws_key_pair" "deployer" {
  key_name   = "githubkeys"
  public_key = file("${path.module}/githubkeys.pub")
}

resource "aws_security_group" "app_server_sg" {
  name        = "app-server-sg"
  description = "Allow SSH and HTTP inbound traffic"
  vpc_id      = null # If you have a VPC, set the VPC ID here, otherwise remove this line for default VPC

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
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

resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.app_server_sg.id]

  tags = {
    Name = "devops-app-server"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -",
      "sudo apt-get install -y nodejs nginx git mysql-client",
      "git clone https://github.com/irvanmlambo/IaC.git",
      "cd IaC && npm install && npm run build && npm start &"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2_user"
    private_key = file(var.private_key_path)
    host        = self.public_ip
  }
}

resource "aws_db_instance" "mysql_db" {
  engine             = "mysql"
  engine_version     = "8.0"
  instance_class     = "db.t2.micro"
  allocated_storage  = 20
  db_name            = "devopsdb"
  username           = var.db_username
  password           = var.db_password
  parameter_group_name = "default.mysql8.0"
  publicly_accessible  = true
  skip_final_snapshot  = true
}