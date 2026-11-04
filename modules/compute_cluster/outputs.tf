# modules/compute_cluster/outputs.tf

output "lb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "The public DNS address of the application load balancer"
}

output "app_security_group_id" {
  value       = aws_security_group.app.id
  description = "Exposed identification string mapping our worker cluster firewalls"
}