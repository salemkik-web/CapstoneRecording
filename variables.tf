variable "region" { default = "us-west-2" }

variable "vpc_cidr" { default = "10.0.0.0/16" }

variable "public_subnets" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "allowed_ssh_ip" {
  description = "Your IP"
  default     = "1.2.3.4/32"
}

variable "instance_type" { default = "t3.micro" }

variable "db_name" { default = "wordpress" }
variable "db_user" { default = "admin" }
variable "db_password" { default = "Password123!" }
