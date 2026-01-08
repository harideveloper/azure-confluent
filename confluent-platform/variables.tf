variable "resource_group_name" {
  description = "Azure resource group name from az-platform"
  type        = string
}

variable "location" {
  description = "Azure region from az-platform"
  type        = string
}

variable "subnet_id" {
  description = "Azure subnet ID from az-platform"
  type        = string
}

variable "vnet_id" {
  description = "Azure VNet ID from az-platform"
  type        = string
}


variable "kafka_cluster_name" {
  description = "Kafka cluster name"
  type        = string
}

variable "kafka_cluster_cku" {
  description = "Number of CKUs (min 1)"
  type        = number
  default     = 1
}

variable "kafka_cluster_availability" {
  description = "SINGLE_ZONE or MULTI_ZONE"
  type        = string
  default     = "MULTI_ZONE"
}

variable "kafka_topics" {
  description = "Kafka topics configuration"
  type = map(object({
    partitions_count = number
    retention_ms     = number
    cleanup_policy   = string
    compression_type = string
  }))
  default = {
    "github-workflows" = {
      partitions_count = 6
      retention_ms     = 604800000
      cleanup_policy   = "delete"
      compression_type = "gzip"
    }
    "optimization-results" = {
      partitions_count = 3
      retention_ms     = 2592000000
      cleanup_policy   = "delete"
      compression_type = "gzip"
    }
    "agent-events" = {
      partitions_count = 6
      retention_ms     = 604800000
      cleanup_policy   = "delete"
      compression_type = "snappy"
    }
  }
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Azure resource tags"
  type        = map(string)
}

variable "subscription" {
  description = "Azure subscription id"
  type        = string
}

variable "mongodb_connection_uri" {
  description = "MongoDB connection URI (from mongo-platform)"
  type        = string
  sensitive   = true
}

variable "mongodb_username" {
  description = "MongoDB username (from mongo-platform)"
  type        = string
  sensitive   = true
}

variable "mongodb_password" {
  description = "MongoDB password (from mongo-platform)"
  type        = string
  sensitive   = true
}

variable "mongodb_database" {
  description = "MongoDB database name"
  type        = string
  default     = "kafka_sink_db"
}

variable "mongodb_collection" {
  description = "MongoDB collection name"
  type        = string
  default     = "events"
}

# Connector Configuration
variable "connector_name" {
  description = "MongoDB Sink Connector name"
  type        = string
  default     = "mongodb-sink-connector"
}

variable "connector_topic" {
  description = "Kafka topic to read from"
  type        = string
  default     = "github-workflows"
}

variable "connector_tasks_max" {
  description = "Maximum number of connector tasks"
  type        = number
  default     = 1
}

