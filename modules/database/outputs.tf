# modules/database/outputs.tf

output "db_endpoint" {
  value       = aws_db_instance.postgres.endpoint
  description = "The isolated internal cluster endpoint used to interface with datastores securely"
}