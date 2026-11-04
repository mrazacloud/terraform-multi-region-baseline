# modules/database/variables.tf

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "app_security_group_id" {
  type = string
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}

variable "database_name" {
  type    = string
  default = "clinical_registry"
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "kms_key_arn" {
  type        = string
  description = "KMS Key ARN tracking customer managed keys for data disk encryption"
}