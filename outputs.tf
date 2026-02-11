output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.wordpress.endpoint
}

output "alb_dns_name" {
  value = aws_lb.wp_alb.dns_name
}