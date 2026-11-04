# environments/production/variables.tf

variable "aws_region" {
  type        = string
  description = "The target AWS deployment region for production infrastructure"
  default     = "us-east-1"
}

variable "production_ami_id" {
  type        = string
  description = "The verified, hardened base Amazon Machine Image ID for the app servers"
  default     = "ami-0c7217cdde317cfec"
}