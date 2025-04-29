output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "The zone ID of the ALB"
  value       = aws_lb.main.zone_id
}

output "alb_arn" {
  description = "The ARN of the ALB"
  value       = aws_lb.main.arn
}

output "target_group_arn" {
  description = "The ARN of the target group"
  value       = aws_lb_target_group.this.arn
}

output "target_group_name" {
  description = "The Name of the target group"
  value       = aws_lb_target_group.this.name
}

output "http_listener_arn" {
  description = "The ARN of the HTTP listener"
  value       = aws_lb_listener.http.arn
}

# TODO: 추후 HTTPS 설정 시 활성화
# output "https_listener_arn" {
#   description = "The ARN of the HTTPS listener (to be enabled later)"
#   # value       = aws_lb_listener.https.arn # Uncomment when HTTPS listener is created
# } 
