terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.80"
    }
    confluent = {
      source  = "confluentinc/confluent"
      version = "~> 1.60"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "confluent" {
  # Reads from environment variables:
  # CONFLUENT_CLOUD_API_KEY
  # CONFLUENT_CLOUD_API_SECRET
}