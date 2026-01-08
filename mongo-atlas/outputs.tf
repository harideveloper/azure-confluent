output "mongodb_project_id" {
  description = "MongoDB project ID"
  value       = mongodbatlas_project.main.id
}

output "mongodb_cluster_id" {
  description = "MongoDB cluster ID"
  value       = mongodbatlas_cluster.main.cluster_id
}

output "mongodb_cluster_name" {
  description = "MongoDB cluster name"
  value       = mongodbatlas_cluster.main.name
}

output "mongodb_connection_string" {
  description = "MongoDB connection string"
  value       = mongodbatlas_cluster.main.connection_strings[0].standard_srv
  sensitive   = true
}

output "mongodb_private_connection_string" {
  description = "MongoDB private connection string"
  value       = mongodbatlas_cluster.main.connection_strings[0].private_srv
  sensitive   = true
}

output "mongodb_username" {
  description = "MongoDB username"
  value       = mongodbatlas_database_user.kafka_user.username
}

output "mongodb_password" {
  description = "MongoDB password"
  value       = mongodbatlas_database_user.kafka_user.password
  sensitive   = true
}

output "connection_details" {
  description = "MongoDB connection details"
  value = <<-EOT
  
  ========================================
  MONGODB CONNECTION DETAILS
  ========================================
  
  Cluster:    ${mongodbatlas_cluster.main.name}
  Connection: ${mongodbatlas_cluster.main.connection_strings[0].private_srv}
  
  Username:   ${mongodbatlas_database_user.kafka_user.username}
  Password:   ${mongodbatlas_database_user.kafka_user.password}
  
  Database:   ${var.database_name}
  Collection: ${var.collection_name}
  
  ========================================
  EOT
  sensitive = true
}