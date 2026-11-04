# environments/azure_production/main.tf

terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# 1. Foundation Resource Group
resource "azurerm_resource_group" "main" {
  name     = "production-rg"
  location = var.azure_region
}

# 2. Secure Perimeter Virtual Network (VNet)
resource "azurerm_virtual_network" "vnet" {
  name                = "production-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# 3. Secure Private Application Subnet
resource "azurerm_subnet" "private" {
  name                 = "production-private-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

# 4. Network Security Group (Acts like AWS Security Group)
resource "azurerm_network_security_group" "nsg" {
  name                = "production-app-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "AllowAppTraffic"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "VirtualNetwork" # Restricts ingress internally
    destination_address_prefix = "*"
  }
}