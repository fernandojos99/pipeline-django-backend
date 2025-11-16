output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.app.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.web_tg.arn
}
