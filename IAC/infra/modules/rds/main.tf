resource "aws_db_subnet_group" "this" {
  name        = "${var.name}-db-subnet-group"
  subnet_ids  = var.subnet_ids
  description = "Subnet group cho RDS PostgreSQL trong cac Private Subnets"

  tags = {
    Name = "${var.name}-db-subnet-group"
  }
}

resource "aws_db_instance" "postgres" {
  identifier             = "${var.name}-postgres"
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  max_allocated_storage  = var.max_allocated_storage
  storage_type           = "gp3"

  db_name  = var.db_name
  username = var.username
  password = var.password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.security_group_id]

  publicly_accessible = false
  skip_final_snapshot = true
  deletion_protection = false

  # Che do sao luu tu dong (Automated Daily Backups)
  backup_retention_period   = 1
  backup_window             = "03:00-04:00"
  maintenance_window        = "Mon:04:30-Mon:05:30"
  auto_minor_version_upgrade = true

  tags = {
    Name        = "${var.name}-rds-postgres"
    Environment = var.name
    ManagedBy   = "Terraform"
  }
}
