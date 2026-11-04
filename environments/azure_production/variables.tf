# environments/azure_production/variables.tf

variable "azure_region" {
  type        = string
  description = "The target Azure deployment location for production"
  default     = "eastus"
}