variable "region" {
  default     = "eu-west-1"
}

variable "key_name" {
  description = "Name of the SSH key pair to use for the EC2 instance"
  default     = "my-key-pair" # Replace with your actual key pair name
}

variable "db_username" {
  description = "Username for the RDS database"
  default     = "admin"
}

variable "db_password" {
  description = "Password for the RDS database"
  default     = "MySecurePwd123!@#$%^&*()"  # Meets all AWS RDS requirements
}