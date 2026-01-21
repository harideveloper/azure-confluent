terraform {
  required_providers {
    confluent = {
      source  = "confluentinc/confluent"
      version = "~> 2.0.0"
    }
  }
}

provider "confluent" {
  cloud_api_key    = var.confluent_cloud_api_key
  cloud_api_secret = var.confluent_cloud_api_secret
}

# Confluent Environment
resource "confluent_environment" "test" {
  display_name = "provisioner-test"
  
  lifecycle {
    prevent_destroy = false
  }
}

# Basic Kafka Cluster (FREE TIER)
resource "confluent_kafka_cluster" "basic" {
  display_name = "provisioner-test-cluster"
  availability = "SINGLE_ZONE"
  cloud        = "AZURE"
  region       = var.location
  
  basic {}

  environment {
    id = confluent_environment.test.id
  }
  
  lifecycle {
    prevent_destroy = false
  }
}

# Service Account for Provisioner
resource "confluent_service_account" "provisioner" {
  display_name = "kafka-provisioner-sa"
  description  = "Service account for Kafka provisioner API"
  
  lifecycle {
    prevent_destroy = false
  }
}

# Service Account for managing ACLs (admin)
resource "confluent_service_account" "admin" {
  display_name = "kafka-admin-sa"
  description  = "Admin service account for managing ACLs"
  
  lifecycle {
    prevent_destroy = false
  }
}

# Role binding: Give admin service account cluster admin permissions
resource "confluent_role_binding" "admin_cluster_admin" {
  principal   = "User:${confluent_service_account.admin.id}"
  role_name   = "CloudClusterAdmin"
  crn_pattern = confluent_kafka_cluster.basic.rbac_crn
  
  lifecycle {
    prevent_destroy = false
  }
}

# API Key for Admin (to create ACLs)
resource "confluent_api_key" "admin_key" {
  display_name = "admin-api-key"
  description  = "Admin API Key for managing ACLs"
  
  owner {
    id          = confluent_service_account.admin.id
    api_version = confluent_service_account.admin.api_version
    kind        = confluent_service_account.admin.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.basic.id
    api_version = confluent_kafka_cluster.basic.api_version
    kind        = confluent_kafka_cluster.basic.kind

    environment {
      id = confluent_environment.test.id
    }
  }
  
  depends_on = [confluent_role_binding.admin_cluster_admin]
  
  lifecycle {
    prevent_destroy = false
  }
}

# API Key for Provisioner
resource "confluent_api_key" "provisioner_key" {
  display_name = "provisioner-api-key"
  description  = "API Key for provisioner to create resources"
  
  owner {
    id          = confluent_service_account.provisioner.id
    api_version = confluent_service_account.provisioner.api_version
    kind        = confluent_service_account.provisioner.kind
  }

  managed_resource {
    id          = confluent_kafka_cluster.basic.id
    api_version = confluent_kafka_cluster.basic.api_version
    kind        = confluent_kafka_cluster.basic.kind

    environment {
      id = confluent_environment.test.id
    }
  }
  
  lifecycle {
    prevent_destroy = false
  }
}

# ACL: Allow provisioner to create topics
resource "confluent_kafka_acl" "provisioner_create_topics" {
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }
  
  resource_type = "TOPIC"
  resource_name = "*"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.provisioner.id}"
  host          = "*"
  operation     = "CREATE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.basic.rest_endpoint
  
  credentials {
    key    = confluent_api_key.admin_key.id
    secret = confluent_api_key.admin_key.secret
  }
  
  depends_on = [confluent_api_key.provisioner_key]
}

# ACL: Allow provisioner to write to topics
resource "confluent_kafka_acl" "provisioner_write" {
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }
  
  resource_type = "TOPIC"
  resource_name = "*"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.provisioner.id}"
  host          = "*"
  operation     = "WRITE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.basic.rest_endpoint
  
  credentials {
    key    = confluent_api_key.admin_key.id
    secret = confluent_api_key.admin_key.secret
  }
  
  depends_on = [confluent_api_key.provisioner_key]
}

# ACL: Allow provisioner to read from topics
resource "confluent_kafka_acl" "provisioner_read" {
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }
  
  resource_type = "TOPIC"
  resource_name = "*"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.provisioner.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.basic.rest_endpoint
  
  credentials {
    key    = confluent_api_key.admin_key.id
    secret = confluent_api_key.admin_key.secret
  }
  
  depends_on = [confluent_api_key.provisioner_key]
}

# ACL: Allow provisioner to describe topics
resource "confluent_kafka_acl" "provisioner_describe" {
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }
  
  resource_type = "TOPIC"
  resource_name = "*"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.provisioner.id}"
  host          = "*"
  operation     = "DESCRIBE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.basic.rest_endpoint
  
  credentials {
    key    = confluent_api_key.admin_key.id
    secret = confluent_api_key.admin_key.secret
  }
  
  depends_on = [confluent_api_key.provisioner_key]
}

# ACL: Allow provisioner to manage consumer groups
resource "confluent_kafka_acl" "provisioner_consumer_groups" {
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }
  
  resource_type = "GROUP"
  resource_name = "*"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.provisioner.id}"
  host          = "*"
  operation     = "READ"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.basic.rest_endpoint
  
  credentials {
    key    = confluent_api_key.admin_key.id
    secret = confluent_api_key.admin_key.secret
  }
  
  depends_on = [confluent_api_key.provisioner_key]
}

resource "confluent_kafka_acl" "provisioner_alter_cluster" {
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }
  
  resource_type = "CLUSTER"
  resource_name = "kafka-cluster"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.provisioner.id}"
  host          = "*"
  operation     = "ALTER"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.basic.rest_endpoint
  
  credentials {
    key    = confluent_api_key.admin_key.id
    secret = confluent_api_key.admin_key.secret
  }
  
  depends_on = [confluent_api_key.provisioner_key]
}

resource "confluent_kafka_acl" "provisioner_delete" {
  kafka_cluster {
    id = confluent_kafka_cluster.basic.id
  }
  
  resource_type = "TOPIC"
  resource_name = "*"
  pattern_type  = "LITERAL"
  principal     = "User:${confluent_service_account.provisioner.id}"
  host          = "*"
  operation     = "DELETE"
  permission    = "ALLOW"
  rest_endpoint = confluent_kafka_cluster.basic.rest_endpoint
  
  credentials {
    key    = confluent_api_key.admin_key.id
    secret = confluent_api_key.admin_key.secret
  }
  
  depends_on = [confluent_api_key.provisioner_key]
}