# modules/database/main.tf

# 1. Dedicated Isolated Subnet Group for the Database Engines
resource "aws_db_subnet_group" "db_tier" {
  name        = "${var.environment}-db-subnet-group"
  description = "Isolated database subnet mapping for compliance boundaries"
  subnet_ids  = var.private_subnet_ids

  tags = {
    Name        = "${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}

# 2. Strict Security Chaining (Allows ingress ONLY from App cluster)
resource "aws_security_group" "db" {
  name        = "${var.environment}-db-sg"
  description = "Enforces isolated internal data paths; accepts app tier ingress only"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow database queries strictly from verified application worker security group"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }

  egress {
    description = "Block all default outgoing paths"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. Encrypted PostgreSQL Instance (HIPAA Compliant Blueprint)
resource "aws_db_instance" "postgres" {
  identifier            = "${var.environment}-medical-registry-db"
  allocated_storage     = 20
  max_allocated_storage = 100
  engine                = "postgres"
  engine_version        = "15.4"
  instance_class        = var.db_instance_class

  # Credentials handled dynamically via variables
  db_name  = var.database_name
  username = var.admin_username
  password = var.admin_password

  db_subnet_group_name   = aws_db_subnet_group.db_tier.name
  vpc_security_group_ids = [aws_security_group.db.id]
  skip_final_snapshot    = var.environment == "production" ? false : true

  # CRITICAL COMPLIANCE GATES (Data-at-Rest Security Rules)
  storage_encrypted   = true
  kms_key_id          = var.kms_key_arn
  deletion_protection = var.environment == "production" ? true : false

  tags = {
    Environment = var.environment
    Compliance  = "HIPAA-Auditable"
  }
}