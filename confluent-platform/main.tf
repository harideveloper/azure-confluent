

# Confluent Environment
resource "confluent_environment" "main" {
  display_name = var.environment
}

# Confluent Network (Private Link)
resource "confluent_network" "azure_private_link" {
  display_name     = "azure-privatelink-network"
  cloud            = "AZURE"
  region           = var.location
  connection_types = ["PRIVATELINK"]
  
  environment {
    id = confluent_environment.main.id
  }

  lifecycle {
    prevent_destroy = false  # Change true to false
  }
  
  # dns_config {
  #   resolution = "PRIVATE"
  # }
}

# Private Link Access (Required for Azure!)
resource "confluent_private_link_access" "azure" {
  display_name = "azure-pla-${var.environment}"
  
  azure {
    subscription = var.subscription
  }
  
  environment {
    id = confluent_environment.main.id
  }
  
  network {
    id = confluent_network.azure_private_link.id
  }
}

# Kafka Cluster (Dedicated)
resource "confluent_kafka_cluster" "dedicated" {
  display_name = var.kafka_cluster_name
  availability = var.kafka_cluster_availability
  cloud        = "AZURE"
  region       = var.location
  
  dedicated {
    cku = var.kafka_cluster_cku
  }

  environment {
    id = confluent_environment.main.id
  }

  network {
    id = confluent_network.azure_private_link.id
  }

  lifecycle {
    prevent_destroy = false
  }
}

# Local variables for DNS
locals {
  dns_domain = confluent_network.azure_private_link.dns_domain
  network_id = split(".", local.dns_domain)[0]
}

# Private DNS Zone
resource "azurerm_private_dns_zone" "confluent" {
  name                = local.dns_domain
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Link DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "confluent" {
  name                  = "confluent-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.confluent.name
  virtual_network_id    = var.vnet_id
}

# Azure Private Endpoint (For Single Zone)
resource "azurerm_private_endpoint" "confluent" {
  name                = "${var.environment}-confluent-private-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id
  tags                = var.tags

  private_service_connection {
    name                              = "confluent-privatelink"
    private_connection_resource_alias = values(confluent_network.azure_private_link.azure[0].private_link_service_aliases)[0]
    is_manual_connection              = true
    request_message                   = "Confluent Kafka Private Link"
  }

  depends_on = [
    confluent_kafka_cluster.dedicated,
    confluent_private_link_access.azure
  ]

  lifecycle {
    prevent_destroy = false
  }
}

# DNS A Record (Wildcard)
resource "azurerm_private_dns_a_record" "confluent_wildcard" {
  name                = "*"
  zone_name           = azurerm_private_dns_zone.confluent.name
  resource_group_name = var.resource_group_name
  ttl                 = 60
  records             = [azurerm_private_endpoint.confluent.private_service_connection[0].private_ip_address]
}

# Service Account
resource "confluent_service_account" "app_manager" {
  display_name = "app-manager-${var.environment}"
  description  = "Service account for hc"
}

# Kafka API Key (with DNS dependency)
resource "confluent_api_key" "app_manager_kafka_api_key" {
  display_name = "app-manager-kafka-api-key"
  description  = "Kafka API Key for applications"
  
  owner {
    id          = confluent_service_account.app_manager.id
    api_version = confluent_service_account.app_manager.api_version
    kind        = confluent_service_account.app_manager.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.dedicated.id
    api_version = confluent_kafka_cluster.dedicated.api_version
    kind        = confluent_kafka_cluster.dedicated.kind

    environment {
      id = confluent_environment.main.id
    }
  }

  # Critical: Wait for DNS setup to complete
  depends_on = [
    confluent_private_link_access.azure,
    azurerm_private_endpoint.confluent,
    azurerm_private_dns_zone_virtual_network_link.confluent,
    azurerm_private_dns_a_record.confluent_wildcard
  ]
}

# Schema Registry API Key
# resource "confluent_api_key" "schema_registry_api_key" {
#   display_name = "schema-registry-api-key"
#   description  = "Schema Registry API Key"
  
#   owner {
#     id          = confluent_service_account.app_manager.id
#     api_version = confluent_service_account.app_manager.api_version
#     kind        = confluent_service_account.app_manager.kind
#   }

#   managed_resource {
#     id          = confluent_schema_registry_cluster.essentials.id
#     api_version = confluent_schema_registry_cluster.essentials.api_version
#     kind        = confluent_schema_registry_cluster.essentials.kind

#     environment {
#       id = confluent_environment.main.id
#     }
#   }
# }

# ACL: WRITE
resource "confluent_kafka_acl" "app_manager_write" {
  kafka_cluster {
    id = confluent_kafka_cluster.dedicated.id
  }
  
  resource_type = "TOPIC"
  resource_name = "*"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app_manager.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.dedicated.rest_endpoint
  
  credentials {
    key    = confluent_api_key.app_manager_kafka_api_key.id
    secret = confluent_api_key.app_manager_kafka_api_key.secret
  }
}

# ACL: READ
resource "confluent_kafka_acl" "app_manager_read" {
  kafka_cluster {
    id = confluent_kafka_cluster.dedicated.id
  }
  
  resource_type = "TOPIC"
  resource_name = "*"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app_manager.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.dedicated.rest_endpoint
  
  credentials {
    key    = confluent_api_key.app_manager_kafka_api_key.id
    secret = confluent_api_key.app_manager_kafka_api_key.secret
  }
}

# ACL: CREATE
resource "confluent_kafka_acl" "app_manager_create" {
  kafka_cluster {
    id = confluent_kafka_cluster.dedicated.id
  }
  
  resource_type = "TOPIC"
  resource_name = "*"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app_manager.id}"
  host          = "*"
  operation     = "CREATE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.dedicated.rest_endpoint
  
  credentials {
    key    = confluent_api_key.app_manager_kafka_api_key.id
    secret = confluent_api_key.app_manager_kafka_api_key.secret
  }
}

# ACL: Consumer Group READ
resource "confluent_kafka_acl" "app_manager_consumer_group" {
  kafka_cluster {
    id = confluent_kafka_cluster.dedicated.id
  }
  
  resource_type = "GROUP"
  resource_name = "*"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.app_manager.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.dedicated.rest_endpoint
  
  credentials {
    key    = confluent_api_key.app_manager_kafka_api_key.id
    secret = confluent_api_key.app_manager_kafka_api_key.secret
  }
}

# Kafka Topics
resource "confluent_kafka_topic" "topics" {
  for_each = var.kafka_topics

  kafka_cluster {
    id = confluent_kafka_cluster.dedicated.id
  }
  
  topic_name       = each.key
  partitions_count = each.value.partitions_count
  rest_endpoint    = confluent_kafka_cluster.dedicated.rest_endpoint
  
  config = {
    "retention.ms"      = tostring(each.value.retention_ms)
    "cleanup.policy"    = each.value.cleanup_policy
    "compression.type"  = each.value.compression_type
    "max.message.bytes" = "2097164"
  }

  credentials {
    key    = confluent_api_key.app_manager_kafka_api_key.id
    secret = confluent_api_key.app_manager_kafka_api_key.secret
  }

  lifecycle {
    prevent_destroy = false  # Change true to false
  }
}



# ============================================
# MONGODB SINK CONNECTOR
# ============================================

# MongoDB Sink Connector
resource "confluent_connector" "mongodb_sink" {
  environment {
    id = confluent_environment.main.id
  }

  kafka_cluster {
    id = confluent_kafka_cluster.dedicated.id
  }

  config_sensitive = {
    "connection.uri"      = var.mongodb_connection_uri
    "connection.username" = var.mongodb_username
    "connection.password" = var.mongodb_password
  }

  config_nonsensitive = {
    "connector.class"          = "MongoDbAtlasSink"
    "name"                     = var.connector_name
    "kafka.auth.mode"          = "SERVICE_ACCOUNT"
    "kafka.service.account.id" = confluent_service_account.app_manager.id
    "topics"                   = var.connector_topic
    "input.data.format"        = "JSON"
    "max.num.retries"          = "3"
    "retries.defer.timeout"    = "5000"
    "max.batch.size"           = "0"
    "tasks.max"                = tostring(var.connector_tasks_max)
    
    # MongoDB Configuration
    "database"                 = var.mongodb_database
    "collection"               = var.mongodb_collection
    
    # Write Strategy
    "writemodel.strategy"      = "com.mongodb.kafka.connect.sink.writemodel.strategy.ReplaceOneDefaultStrategy"
    "document.id.strategy"     = "com.mongodb.kafka.connect.sink.processor.id.strategy.PartialValueStrategy"
    "document.id.strategy.partial.value.projection.type" = "AllowList"
    "document.id.strategy.partial.value.projection.list" = "id"
    
    # Error Handling
    "errors.tolerance"         = "all"
    "errors.log.enable"        = "true"
    "errors.log.include.messages" = "true"
    
    # Dead Letter Queue
    "errors.deadletterqueue.topic.name" = "${var.connector_topic}-dlq"
    "errors.deadletterqueue.topic.replication.factor" = "3"
  }

  depends_on = [
    confluent_kafka_cluster.dedicated,
    confluent_kafka_acl.app_manager_write,
    confluent_kafka_acl.app_manager_read,
    confluent_kafka_topic.topics
  ]

  lifecycle {
    prevent_destroy = false
  }
}
