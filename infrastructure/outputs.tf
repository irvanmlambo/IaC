output "ec2_public_ip" {
  value = aws_instance.app_server.public_ip
}

output "application_url" {
  value = "http://${aws_instance.app_server.public_ip}"
}

output "ssh_connection" {
  value = "ssh -i infrastructure/githubkeys ubuntu@${aws_instance.app_server.public_ip}"
}

output "db_endpoint" {
  value = aws_db_instance.mysql_db.endpoint
}

output "db_connection_string" {
  value = "mysql://${var.db_username}:${var.db_password}@${aws_db_instance.mysql_db.endpoint}/${aws_db_instance.mysql_db.db_name}"
  sensitive = true
}