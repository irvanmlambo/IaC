# Use existing key pair instead of creating a new one
data "aws_key_pair" "deployer" {
  key_name = "githubkeys"
}

# Get the latest Ubuntu 22.04 LTS AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Use data source to reference existing security group
data "aws_security_group" "app_server_sg" {
  name = "app-server-sg"
}

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro" # Free tier eligible (use t2.micro if t3.micro not available in your region)
  key_name      = data.aws_key_pair.deployer.key_name
  vpc_security_group_ids = [data.aws_security_group.app_server_sg.id]

  # Ensure EBS root volume is free tier eligible
  root_block_device {
    volume_size = 8 # Free tier allows up to 30GB total
    volume_type = "gp3" # Free tier eligible
  }

  tags = {
    Name = "devops-app-server"
  }

  # Wait for the instance to be ready
  provisioner "local-exec" {
    command = "echo 'Instance IP: ${self.public_ip}, Key: ${data.aws_key_pair.deployer.key_name}'"
  }

  provisioner "remote-exec" {
    inline = [
      "echo 'SSH connection successful'",
      "whoami",
      "sudo apt-get update",
      "curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -",
      "sudo apt-get install -y nodejs nginx git mysql-client",
      "git clone https://github.com/irvanmlambo/IaC.git",
      "cd IaC && npm install && npm run build && npm start &"
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = var.private_key
      host        = self.public_ip
      timeout     = "10m"
      agent       = false
      target_platform = "unix"
    }
  }
}

resource "aws_db_instance" "mysql_db" {
  engine               = "mysql"
  engine_version       = "8.0.35"
  instance_class       = "db.t3.micro" # Free tier eligible (use db.t2.micro if t3.micro not available)
  allocated_storage    = 20 # Free tier allows up to 20GB
  db_name              = "devopsdb"
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql8.0"
  publicly_accessible  = true
  skip_final_snapshot  = true
  # Free tier: only one RDS instance per month is free
}