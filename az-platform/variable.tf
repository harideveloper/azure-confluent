# ============================================
# AZURE PLATFORM VARIABLES
# ============================================

variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
  default     = "rg-confluent-kafka-uksouth"
}

variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "uksouth"
  
  validation {
    condition     = can(regex("^(uksouth|ukwest)$", var.location))
    error_message = "Location must be uksouth or ukwest for UK regions."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = can(regex("^(dev|staging|prod)$", var.environment))
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "vnet_address_space" {
  description = "Address space for the Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "kafka_subnet_prefix" {
  description = "Address prefix for Kafka subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "Confluent-Kafka"
    ManagedBy   = "Terraform"
    Environment = "dev"
    Owner       = "Hari"
  }
}

# Network Security Group Rules Configuration
variable "allow_kafka_port" {
  description = "Allow Kafka broker port (9092)"
  type        = bool
  default     = true
}

variable "allow_schema_registry_port" {
  description = "Allow Schema Registry port (443)"
  type        = bool
  default     = true
}

variable "allowed_source_ips" {
  description = "Source IP ranges allowed to access Kafka (use * for all, or specific CIDR)"
  type        = list(string)
  default     = ["10.0.0.0/16"]  # Only allow traffic from within VNet by default
}