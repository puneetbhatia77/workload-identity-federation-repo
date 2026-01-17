# Main Terraform configuration for Azure resources using Workload Identity Federation
# This example creates a resource group and storage account

terraform {
  required_version = ">= 1.6.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Configure Azure Provider with Workload Identity Federation
provider "azurerm" {
  features {}
  
  # Use workload identity federation (OIDC) for authentication
  # Set use_oidc = true to enable workload identity
  use_oidc = true
  
  # Authentication details are provided via environment variables:
  # ARM_CLIENT_ID       - Application (client) ID
  # ARM_TENANT_ID       - Directory (tenant) ID
  # ARM_SUBSCRIPTION_ID - Azure subscription ID
  # ARM_USE_OIDC=true   - Enable OIDC authentication
}

# Variables
variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "myproject"
}

# Data source to get current subscription
data "azurerm_subscription" "current" {}

data "azurerm_client_config" "current" {}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.project_name}-${var.environment}"
  location = var.location
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    DeployedBy  = "WorkloadIdentityFederation"
    CreatedDate = timestamp()
  }
}

# Storage Account
resource "azurerm_storage_account" "main" {
  name                     = "st${var.project_name}${var.environment}${substr(md5(azurerm_resource_group.main.id), 0, 6)}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Virtual Network (Optional - uncomment if needed)
# resource "azurerm_virtual_network" "main" {
#   name                = "vnet-${var.project_name}-${var.environment}"
#   address_space       = ["10.0.0.0/16"]
#   location            = azurerm_resource_group.main.location
#   resource_group_name = azurerm_resource_group.main.name
#   
#   tags = {
#     Environment = var.environment
#     Project     = var.project_name
#     ManagedBy   = "Terraform"
#   }
# }

# Subnet (Optional - uncomment if needed)
# resource "azurerm_subnet" "main" {
#   name                 = "snet-${var.project_name}-${var.environment}"
#   resource_group_name  = azurerm_resource_group.main.name
#   virtual_network_name = azurerm_virtual_network.main.name
#   address_prefixes     = ["10.0.1.0/24"]
# }

# Key Vault (Optional - uncomment if needed)
# resource "azurerm_key_vault" "main" {
#   name                       = "kv-${var.project_name}-${var.environment}"
#   location                   = azurerm_resource_group.main.location
#   resource_group_name        = azurerm_resource_group.main.name
#   tenant_id                  = data.azurerm_client_config.current.tenant_id
#   sku_name                   = "standard"
#   soft_delete_retention_days = 7
#   purge_protection_enabled   = false
#   
#   tags = {
#     Environment = var.environment
#     Project     = var.project_name
#     ManagedBy   = "Terraform"
#   }
# }

# Outputs
output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "The ID of the resource group"
  value       = azurerm_resource_group.main.id
}

output "storage_account_name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.main.name
}

output "storage_account_id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.main.id
}

output "subscription_id" {
  description = "Current Azure subscription ID"
  value       = data.azurerm_subscription.current.subscription_id
}

output "tenant_id" {
  description = "Current Azure tenant ID"
  value       = data.azurerm_client_config.current.tenant_id
}
