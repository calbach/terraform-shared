resource "google_storage_bucket_object" "docker-compose" {
  count = length(var.mongodb_roles)
  name   = "${element(split("/", element(module.instances.instance_names, count.index)), length(split("/", element(module.instances.instance_names, count.index))) - 1)}/configs/docker-compose.yaml"
  content = <<EOT
version: '2'
services:
  mongodb:
    image: bitnami/mongodb:3.4.4-r1
    ports:
      - "${var.mongodb_host_port}:${var.mongodb_container_port}"
    environment:
      - MONGODB_ROOT_PASSWORD=${random_id.mongodb-root-password.hex}
      - MONGODB_PRIMARY_ROOT_PASSWORD=${random_id.mongodb-root-password.hex}
      - MONGODB_USERNAME=${var.mongodb_app_username}
      - MONGODB_PASSWORD=${random_id.mongodb-user-password.hex}
      - MONGODB_DATABASE=${var.mongodb_database}
      - MONGODB_PRIMARY_PORT=${var.mongodb_container_port}
      - MONGODB_REPLICA_SET_MODE=${element(var.mongodb_roles, count.index)}
      - MONGODB_REPLICA_SET_MODE=${random_string.mongodb-replica-set-key.result}
    volumes:
      - ${var.mongodb_data_path}:/bitnami
    restart: always
EOT
  bucket = "${var.config_bucket_name}"
  depends_on = [ "module.instances" ]
}
