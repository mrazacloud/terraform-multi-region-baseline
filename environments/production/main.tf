# environments/production/main.tf

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# 1. Initialize the Base Networking Topology
module "networking" {
  source = "../../modules/networking"

  environment          = "production"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b"]
}

# 2. Deploy the Secure App Cluster directly into the Network
module "compute_cluster" {
  source = "../../modules/compute_cluster"

  environment        = "production"
  vpc_id             = module.networking.vpc_id
  public_subnet_ids  = module.networking.public_subnet_ids
  private_subnet_ids = module.networking.private_subnet_ids

  instance_type     = "t3.medium" # Production grade baseline size
  ami_id            = var.production_ami_id
  app_port          = 8080
  min_instances     = 2
  max_instances     = 6
  desired_instances = 2
}

# 3. Initialize Isolated HIPAA-Compliant PostgreSQL Datastore Tier
module "database" {
  source = "../../modules/database"

  environment           = "production"
  vpc_id                = module.networking.vpc_id
  private_subnet_ids    = module.networking.private_subnet_ids
  app_security_group_id = module.compute_cluster.app_security_group_id # Links directly to app SG

  db_instance_class = "db.t3.medium"
  admin_username    = "db_admin_prod"
  admin_password    = "SecureEnterprisePassword2026!" # Example mock string
  kms_key_arn       = "arn:aws:kms:us-east-1:123456789012:key/mock-kms-uuid"
}