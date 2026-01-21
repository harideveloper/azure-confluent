output "environment_id" {
  value = confluent_environment.test.id
}

output "cluster_id" {
  value = confluent_kafka_cluster.basic.id
}

output "bootstrap_servers" {
  value = confluent_kafka_cluster.basic.bootstrap_endpoint
}

output "rest_endpoint" {
  value = confluent_kafka_cluster.basic.rest_endpoint
}

output "provisioner_api_key" {
  value     = confluent_api_key.provisioner_key.id
  sensitive = false
}

output "provisioner_api_secret" {
  value     = confluent_api_key.provisioner_key.secret
  sensitive = true
}

output "service_account_id" {
  value = confluent_service_account.provisioner.id
}

output "cluster_details" {
  value = {
    cluster_id = confluent_kafka_cluster.basic.id
    environment_id = confluent_environment.test.id
    bootstrap_servers = confluent_kafka_cluster.basic.bootstrap_endpoint
    rest_endpoint = confluent_kafka_cluster.basic.rest_endpoint
  }
}

output "provisioner_credentials" {
  value = {
    service_account_id = confluent_service_account.provisioner.id
    api_key = confluent_api_key.provisioner_key.id
  }
  sensitive = false
}
