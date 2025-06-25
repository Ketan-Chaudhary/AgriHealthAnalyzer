# Output - VPC ID and DNS name of the Load Balancer
output "vpc_id" {
  value = aws_vpc.main.id
}

output "alb_dns" {
  value = aws_lb.app_lb.dns_name
}

