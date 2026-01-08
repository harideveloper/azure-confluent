# -----------------------------
# MongoDB Atlas Project
# -----------------------------
resource "mongodbatlas_project" "main" {
  name   = var.mongodb_project_name
  org_id = var.mongodb_atlas_org_id
}

# -----------------------------
# MongoDB Atlas Cluster
# -----------------------------
resource "mongodbatlas_cluster" "main" {
  project_id   = mongodbatlas_project.main.id
  name         = var.mongodb_cluster_name
  cluster_type = "REPLICASET"

  provider_name               = "AZURE"
  provider_instance_size_name = var.mongodb_cluster_tier
  
  replication_specs {
    num_shards = 1
    
    regions_config {
      region_name     = var.mongodb_cluster_region
      electable_nodes = 3
      priority        = 7
      read_only_nodes = 0
    }
  }

  mongo_db_major_version       = var.mongodb_version
  auto_scaling_disk_gb_enabled = true
  cloud_backup                 = true

  advanced_configuration {
    javascript_enabled           = true
    minimum_enabled_tls_protocol = "TLS1_2"
  }

  lifecycle {
    prevent_destroy = false
  }
}

# -----------------------------
# MongoDB Atlas PrivateLink (Azure)
# -----------------------------
resource "mongodbatlas_privatelink_endpoint" "main" {
  project_id    = mongodbatlas_project.main.id
  provider_name = "AZURE"
  region        = var.mongodb_cluster_region
}

# -----------------------------
# Azure Private Endpoint
# -----------------------------
resource "azurerm_private_endpoint" "mongodb" {
  name                = "${var.environment}-mongodb-private-endpoint"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.mongo_subnet_id
  tags                = var.tags

  # IMPORTANT:
  # For Azure + Atlas: use MANUAL mode and NO group_id/subresource_names
  private_service_connection {
    name                           = "mongodb-privatelink"
    private_connection_resource_id = mongodbatlas_privatelink_endpoint.main.private_link_service_resource_id
    is_manual_connection           = true
    request_message                = "Requesting PrivateLink connection to MongoDB Atlas"
  }

  depends_on = [
    mongodbatlas_privatelink_endpoint.main
  ]
}

# -----------------------------
# MongoDB Atlas PrivateLink Endpoint Service (Azure)
# -----------------------------
resource "mongodbatlas_privatelink_endpoint_service" "main" {
  project_id                  = mongodbatlas_project.main.id
  private_link_id             = mongodbatlas_privatelink_endpoint.main.private_link_id
  # We use the main Private Endpoint's ID for the connection request ID
  endpoint_service_id         = azurerm_private_endpoint.mongodb.id 
  provider_name               = "AZURE"
  
  # CRITICAL ADDITION: The required Private IP Address
  private_endpoint_ip_address = azurerm_private_endpoint.mongodb.private_service_connection[0].private_ip_address
}

# -----------------------------
# Database User
# -----------------------------
resource "random_password" "kafka_user_password" {
  length  = 32
  special = true
}

resource "mongodbatlas_database_user" "kafka_user" {
  username           = "kafka-connector"
  password           = random_password.kafka_user_password.result
  project_id         = mongodbatlas_project.main.id
  auth_database_name = "admin"

  roles {
    role_name     = "readWriteAnyDatabase"
    database_name = "admin"
  }

  roles {
    role_name     = "dbAdminAnyDatabase"
    database_name = "admin"
  }

  scopes {
    name = mongodbatlas_cluster.main.name
    type = "CLUSTER"
  }

  depends_on = [
    mongodbatlas_cluster.main
  ]
}

# -----------------------------
# IP Access List (VNet only)
# -----------------------------
resource "mongodbatlas_project_ip_access_list" "vnet" {
  project_id = mongodbatlas_project.main.id
  cidr_block = "10.0.0.0/16"
  comment    = "VNet access via Private Link"
}

