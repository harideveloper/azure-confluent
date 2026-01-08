output "environment_id" {
  description = "Confluent environment ID"
  value       = confluent_environment.main.id
}

output "kafka_cluster_id" {
  description = "Kafka cluster ID"
  value       = confluent_kafka_cluster.dedicated.id
}

output "kafka_bootstrap_endpoint" {
  description = "Kafka bootstrap endpoint"
  value       = confluent_kafka_cluster.dedicated.bootstrap_endpoint
}

output "kafka_rest_endpoint" {
  description = "Kafka REST endpoint"
  value       = confluent_kafka_cluster.dedicated.rest_endpoint
}

# output "schema_registry_endpoint" {
#   description = "Schema Registry endpoint"
#   value       = confluent_schema_registry_cluster.essentials.rest_endpoint
# }

output "service_account_id" {
  description = "Service account ID"
  value       = confluent_service_account.app_manager.id
}

output "kafka_api_key" {
  description = "Kafka API Key"
  value       = confluent_api_key.app_manager_kafka_api_key.id
}

output "kafka_api_secret" {
  description = "Kafka API Secret"
  value       = confluent_api_key.app_manager_kafka_api_key.secret
  sensitive   = true
}

# output "schema_registry_api_key" {
#   description = "Schema Registry API Key"
#   value       = confluent_api_key.schema_registry_api_key.id
# }

# output "schema_registry_api_secret" {
#   description = "Schema Registry API Secret"
#   value       = confluent_api_key.schema_registry_api_key.secret
#   sensitive   = true
# }

output "topics_created" {
  description = "List of topics created"
  value       = keys(var.kafka_topics)
}

output "private_endpoint_id" {
  description = "Azure Private Endpoint ID"
  value       = azurerm_private_endpoint.confluent.id
}

output "connection_config" {
  description = "Kafka connection configuration"
  value = {
    bootstrap_servers = confluent_kafka_cluster.dedicated.bootstrap_endpoint
    security_protocol = "SASL_SSL"
    sasl_mechanism    = "PLAIN"
    sasl_username     = confluent_api_key.app_manager_kafka_api_key.id
  }
}

output "connection_details" {
  description = "Complete connection details"
  value = <<-EOT
  
  ========================================
  KAFKA CONNECTION DETAILS
  ========================================
  
  Bootstrap Servers: ${confluent_kafka_cluster.dedicated.bootstrap_endpoint}
  Kafka API Key:     ${confluent_api_key.app_manager_kafka_api_key.id}
  Kafka API Secret:  ${confluent_api_key.app_manager_kafka_api_key.secret}

  
  Topics:            ${join(", ", keys(var.kafka_topics))}
  
  ========================================
  EOT
  sensitive = true
}


  
  # Schema Registry:   ${confluent_schema_registry_cluster.essentials.rest_endpoint}
  # SR API Key:        ${confluent_api_key.schema_registry_api_key.id}
  # SR API Secret:     ${confluent_api_key.schema_registry_api_key.secret}

# MongoDB Connector Outputs
output "mongodb_connector_id" {
  description = "MongoDB Sink Connector ID"
  value       = confluent_connector.mongodb_sink.id
}

output "mongodb_connector_name" {
  description = "MongoDB Sink Connector name"
  value       = var.connector_name
}

output "mongodb_connector_status" {
  description = "MongoDB Sink Connector status"
  value       = confluent_connector.mongodb_sink.status
}

output "connector_info" {
  description = "Connector configuration summary"
  value = <<-EOT
  
  ========================================
  MONGODB SINK CONNECTOR
  ========================================
  
  Connector Name: ${var.connector_name}
  Status:         ${confluent_connector.mongodb_sink.status}
  
  Source Topic:   ${var.connector_topic}
  Target DB:      ${var.mongodb_database}
  Target Coll:    ${var.mongodb_collection}
  
  Tasks:          ${var.connector_tasks_max}
  
  ========================================
  EOT
}