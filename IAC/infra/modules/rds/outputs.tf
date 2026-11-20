output "endpoint" {
  description = "Connection endpoint cua RDS PostgreSQL (host:port)"
  value       = aws_db_instance.postgres.endpoint
}

output "address" {
  description = "Hostname cua RDS PostgreSQL"
  value       = aws_db_instance.postgres.address
}

output "port" {
  description = "Port ket noi (5432)"
  value       = aws_db_instance.postgres.port
}

output "db_name" {
  description = "Ten co so du lieu"
  value       = aws_db_instance.postgres.db_name
}

output "username" {
  description = "Master username cua database"
  value       = aws_db_instance.postgres.username
}

output "resource_id" {
  description = "RDS Resource ID"
  value       = aws_db_instance.postgres.resource_id
}
