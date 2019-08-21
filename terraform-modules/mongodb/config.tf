resource "google_storage_bucket_object" "docker-compose" {
  count = length(var.mongodb_roles)
  name   = "${element(split("/", element(module.instances.instance_names, count.index)), length(split("/", element(module.instances.instance_names, count.index))) - 1)}/configs/docker-compose.yaml"
  content = <<EOT
version: '2'
services:
  mongodb:
    user: root
    image: bitnami/mongodb:latest
    ports:
      - "${var.mongodb_host_port}:${var.mongodb_container_port}"
    environment:
      - ${var.mongodb_roles[count.index] == "primary" ? "MONGODB_ROOT_PASSWORD=${var.mongodb_root_password}" : "MONGODB_PRIMARY_ROOT_PASSWORD=${var.mongodb_root_password}"}
      - MONGODB_USERNAME=${var.mongodb_app_username}
      - MONGODB_PASSWORD=${var.mongodb_app_password}
      - MONGODB_DATABASE=${var.mongodb_database}
      - MONGODB_PRIMARY_PORT=${var.mongodb_container_port}
      - MONGODB_REPLICA_SET_MODE=${element(var.mongodb_roles, count.index)}
      - MONGODB_REPLICA_SET_KEY=${var.mongodb_replica_set_key}
      - MONGODB_ADVERTISED_HOSTNAME=${"${substr(google_dns_record_set.dns-a-priv[count.index].name, 0, length(google_dns_record_set.dns-a-priv[count.index].name) - 1)}"}
      ${var.mongodb_roles[count.index] == "primary" ? "" : "- MONGODB_PRIMARY_HOST=${substr(google_dns_record_set.dns-a-priv[0].name, 0, length(google_dns_record_set.dns-a-priv[0].name) - 1)}"}
    volumes:
      - ${var.mongodb_data_path}:/bitnami
    restart: always
EOT
  bucket = "${google_storage_bucket.config-bucket.name}"
  depends_on = [ "module.instances", "google_storage_bucket.config-bucket", "google_dns_record_set.dns-a-priv" ]
}
