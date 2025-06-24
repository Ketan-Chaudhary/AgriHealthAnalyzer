output "vpc_id" {
  value = aws_vpc.main.id
}

output "alb_dsn" {
  value = aws_lb.app_lb.dns_name
}