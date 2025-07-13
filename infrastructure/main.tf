resource "aws_key_pair" "deployer" {
  key_name   = "githubkeys"
  public_key = file("${path.module}/githubkeys.pub")
}

# Use data source to reference existing security group
data "aws_security_group" "app_server_sg" {
  name = "app-server-sg"
}

resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [data.aws_security_group.app_server_sg.id]

  tags = {
    Name = "devops-app-server"
  }

  # Wait for the instance to be ready
  provisioner "local-exec" {
    command = "echo 'Waiting for instance to be ready...'"
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
    user        = "ubuntu"
    private_key = file("${path.module}/githubkeys")
    host        = self.public_ip
    timeout     = "5m"
    agent       = false
    target_platform = "unix"
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