terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
  }

  # Optional: Backend configuration for remote state
  # Uncomment and configure if you want to store state remotely
  # backend "azurerm" {
  #   resource_group_name  = "terraform-state-rg"
  #   storage_account_name = "tfstatexxxxx"
  #   container_name       = "tfstate"
  #   key                  = "az-platform.tfstate"
  # }
}

provider "azurerm" {
  features {}
  
  # Terraform will use your Azure CLI credentials
  # Make sure you've run: az login
}