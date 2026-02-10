variable "aws_region" {
  default = "us-west-2"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr_1" { default = "10.0.1.0/24" }
variable "public_subnet_cidr_2" { default = "10.0.2.0/24" }
variable "private_subnet_cidr_1" { default = "10.0.3.0/24" }
variable "private_subnet_cidr_2" { default = "10.0.4.0/24" }
variable "availability_zone" { default = "us-west-2a" }

variable "instance_type" {
  default = "t3.micro"
}

variable "key_name" {
  default = "vockey"
}

variable "db_name" {
  default = "wordpress"
}

variable "db_user" {
  default = "wpuser"
}

variable "db_password" {
  default = "Password123!"
}

variable "my_ip" {
  description = "95.81.26.151/32"
  default     = "95.81.26.151/32"
}
