# Azure Infrastructure
variable "resource_group_name" {
  description = "Azure resource group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "vnet_id" {
  description = "Azure VNet ID"
  type        = string
}

variable "mongo_subnet_id" {
  description = "Azure MongoDB subnet ID"
  type        = string
}

# MongoDB Atlas
variable "mongodb_atlas_org_id" {
  description = "MongoDB Atlas Organization ID"
  type        = string
}

variable "mongodb_project_name" {
  description = "MongoDB Atlas project name"
  type        = string
  default     = "hc-kafka-project"
}

variable "mongodb_cluster_name" {
  description = "MongoDB cluster name"
  type        = string
  default     = "hc-cluster"
}

variable "mongodb_cluster_tier" {
  description = "MongoDB cluster tier"
  type        = string
  default     = "M10"
}

variable "mongodb_cluster_region" {
  description = "MongoDB Atlas region"
  type        = string
  default     = "UK_SOUTH"
}

variable "mongodb_version" {
  description = "MongoDB version"
  type        = string
  default     = "7.0"
}

variable "database_name" {
  description = "Database name"
  type        = string
  default     = "kafka_sink_db"
}

variable "collection_name" {
  description = "Collection name"
  type        = string
  default     = "events"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Azure tags"
  type        = map(string)
  default = {
    Project     = "hc-earl"
    ManagedBy   = "Terraform"
    Environment = "dev"
    Owner       = "hc"
  }
}