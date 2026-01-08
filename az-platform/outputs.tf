# ============================================
# AZURE PLATFORM OUTPUTS
# ============================================
# These outputs will be used by confluent-platform
# Copy these values to confluent-platform/terraform.tfvars
# ============================================

output "resource_group_name" {
  description = "Name of the Azure resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the Azure resource group"
  value       = azurerm_resource_group.main.id
}

output "location" {
  description = "Azure region where resources are deployed"
  value       = azurerm_resource_group.main.location
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.main.name
}

output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_address_space" {
  description = "Address space of the Virtual Network"
  value       = azurerm_virtual_network.main.address_space
}

output "kafka_subnet_name" {
  description = "Name of the Kafka subnet"
  value       = azurerm_subnet.kafka.name
}

output "kafka_subnet_id" {
  description = "ID of the Kafka subnet (IMPORTANT: Use this in confluent-platform)"
  value       = azurerm_subnet.kafka.id
}

output "kafka_subnet_address_prefix" {
  description = "Address prefix of the Kafka subnet"
  value       = azurerm_subnet.kafka.address_prefixes[0]
}

output "nsg_id" {
  description = "ID of the Network Security Group"
  value       = azurerm_network_security_group.kafka.id
}

output "nsg_name" {
  description = "Name of the Network Security Group"
  value       = azurerm_network_security_group.kafka.name
}

# Summary output for easy copy-paste
output "summary" {
  description = "Summary of created resources for confluent-platform"
  value = {
    resource_group_name = azurerm_resource_group.main.name
    location           = azurerm_resource_group.main.location
    subnet_id          = azurerm_subnet.kafka.id
    vnet_id            = azurerm_virtual_network.main.id
  }
}

# Formatted output for easy copy-paste to confluent-platform
output "confluent_platform_config" {
  description = "Configuration to copy to confluent-platform/terraform.tfvars"
  value = <<-EOT
  
  ========================================
  COPY THESE VALUES TO confluent-platform/terraform.tfvars
  ========================================
  
  resource_group_name = "${azurerm_resource_group.main.name}"
  location           = "${azurerm_resource_group.main.location}"
  subnet_id          = "${azurerm_subnet.kafka.id}"
  vnet_id            = "${azurerm_virtual_network.main.id}"
  
  ========================================
  EOT
}


# MongoDB Subnet Outputs
output "mongo_subnet_name" {
  description = "Name of the MongoDB subnet"
  value       = azurerm_subnet.mongo.name
}

output "mongo_subnet_id" {
  description = "ID of the MongoDB subnet"
  value       = azurerm_subnet.mongo.id
}

output "mongo_subnet_address_prefix" {
  description = "Address prefix of the MongoDB subnet"
  value       = azurerm_subnet.mongo.address_prefixes[0]
}

output "mongo_nsg_id" {
  description = "ID of the MongoDB NSG"
  value       = azurerm_network_security_group.mongo.id
}

# MongoDB Platform Config
output "mongo_platform_config" {
  description = "Configuration for mongo-platform/terraform.tfvars"
  value = <<-EOT
  
  ========================================
  COPY THESE VALUES TO mongo-platform/terraform.tfvars
  ========================================
  
  resource_group_name = "${azurerm_resource_group.main.name}"
  location           = "${azurerm_resource_group.main.location}"
  vnet_id            = "${azurerm_virtual_network.main.id}"
  mongo_subnet_id    = "${azurerm_subnet.mongo.id}"
  
  ========================================
  EOT
}