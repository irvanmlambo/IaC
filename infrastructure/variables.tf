variable "region" {
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  default     = "ami-0c55b159cbfafe1f0" # Example AMI ID, replace with a valid one
}

variable "key_name" {
  description = "Name of the SSH key pair to use for the EC2 instance"
  default     = "my-key-pair" # Replace with your actual key pair name
}

variable "private_key_path" {
  description = "Path to the private key file for SSH access"
  default     = "~/.ssh/my-key-pair.pem" # Replace with your actual private key path
}

variable "db_username" {
  description = "Username for the RDS database"
  default     = "admin"
}

variable "db_password" {
  description = "Password for the RDS database"
  default     = "securepassword123"
}