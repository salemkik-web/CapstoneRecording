output "alb_dns_name" {
  value = aws_lb.wp_alb.dns_name
  description = "DNS name of the WordPress ALB"
}


output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.wordpress.endpoint
}

