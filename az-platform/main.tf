# ============================================
# AZURE PLATFORM - NETWORKING INFRASTRUCTURE
# ============================================
# This creates the foundational Azure networking
# components required for Confluent Cloud connectivity
# ============================================

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags

  lifecycle {
    prevent_destroy = false  # Set to true in production
  }
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "${var.environment}-confluent-vnet"
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  lifecycle {
    prevent_destroy = false  # Set to true in production
  }
}

# Subnet for Kafka connectivity
resource "azurerm_subnet" "kafka" {
  name                 = "kafka-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.kafka_subnet_prefix]

  # Disable private endpoint network policies
  # Required for Azure Private Endpoint to work
  private_endpoint_network_policies_enabled = false

  lifecycle {
    prevent_destroy = false  # Set to true in production
  }
}

# Network Security Group for Kafka subnet
resource "azurerm_network_security_group" "kafka" {
  name                = "${var.environment}-kafka-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  lifecycle {
    prevent_destroy = false  # Set to true in production
  }
}

# NSG Rule: Allow Kafka broker traffic (9092)
resource "azurerm_network_security_rule" "allow_kafka" {
  count = var.allow_kafka_port ? 1 : 0

  name                        = "AllowKafkaBroker"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "9092"
  source_address_prefixes     = var.allowed_source_ips
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.kafka.name
  description                 = "Allow outbound traffic to Kafka brokers on port 9092"
}

# NSG Rule: Allow HTTPS traffic (443) for Schema Registry and REST API
resource "azurerm_network_security_rule" "allow_https" {
  count = var.allow_schema_registry_port ? 1 : 0

  name                        = "AllowHTTPS"
  priority                    = 101
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefixes     = var.allowed_source_ips
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.kafka.name
  description                 = "Allow outbound HTTPS for Schema Registry and Kafka REST API"
}

# NSG Rule: Allow DNS resolution
resource "azurerm_network_security_rule" "allow_dns" {
  name                        = "AllowDNS"
  priority                    = 102
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "53"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.kafka.name
  description                 = "Allow DNS resolution"
}

# NSG Rule: Deny all other outbound traffic (optional - be careful!)
# Uncomment if you want strict control
# resource "azurerm_network_security_rule" "deny_all_outbound" {
#   name                        = "DenyAllOutbound"
#   priority                    = 4000
#   direction                   = "Outbound"
#   access                      = "Deny"
#   protocol                    = "*"
#   source_port_range           = "*"
#   destination_port_range      = "*"
#   source_address_prefix       = "*"
#   destination_address_prefix  = "*"
#   resource_group_name         = azurerm_resource_group.main.name
#   network_security_group_name = azurerm_network_security_group.kafka.name
#   description                 = "Deny all other outbound traffic"
# }

# Associate NSG with Kafka subnet
resource "azurerm_subnet_network_security_group_association" "kafka" {
  subnet_id                 = azurerm_subnet.kafka.id
  network_security_group_id = azurerm_network_security_group.kafka.id

  depends_on = [
    azurerm_network_security_rule.allow_kafka,
    azurerm_network_security_rule.allow_https,
    azurerm_network_security_rule.allow_dns
  ]
}

// Mongo

# ============================================
# MONGODB SUBNET AND NSG (NEW)
# ============================================

# MongoDB Subnet
resource "azurerm_subnet" "mongo" {
  name                 = "mongo-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]

  # Disable private endpoint network policies
  private_endpoint_network_policies_enabled = false

  lifecycle {
    prevent_destroy = false
  }
}

# Network Security Group for MongoDB subnet
resource "azurerm_network_security_group" "mongo" {
  name                = "${var.environment}-mongo-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  lifecycle {
    prevent_destroy = false
  }
}

# NSG Rule: Allow MongoDB from Kafka subnet
resource "azurerm_network_security_rule" "mongo_from_kafka" {
  name                        = "AllowMongoDBFromKafka"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "27017"
  source_address_prefix       = "10.0.1.0/24"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.mongo.name
  description                 = "Allow MongoDB traffic from Kafka subnet"
}

# NSG Rule: Allow HTTPS for MongoDB Atlas API
resource "azurerm_network_security_rule" "mongo_https" {
  name                        = "AllowHTTPS"
  priority                    = 101
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.mongo.name
  description                 = "Allow HTTPS for MongoDB Atlas API"
}

# NSG Rule: Allow DNS
resource "azurerm_network_security_rule" "mongo_dns" {
  name                        = "AllowDNS"
  priority                    = 102
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Udp"
  source_port_range           = "*"
  destination_port_range      = "53"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.mongo.name
  description                 = "Allow DNS resolution"
}

# Associate NSG with MongoDB subnet
resource "azurerm_subnet_network_security_group_association" "mongo" {
  subnet_id                 = azurerm_subnet.mongo.id
  network_security_group_id = azurerm_network_security_group.mongo.id

  depends_on = [
    azurerm_network_security_rule.mongo_from_kafka,
    azurerm_network_security_rule.mongo_https,
    azurerm_network_security_rule.mongo_dns
  ]
}