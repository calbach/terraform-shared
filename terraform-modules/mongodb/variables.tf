# module wide vars
# google project
variable "project" {}

# enable/disable var
variable "enable_flag" {
   default = "1"
}

variable "instance_name" {
  default = "docker-data-node"
  description = "root instance names"
}

variable "instance_region" {
  default = "us-central1"
  description = "The region where instances will be created"
}

variable "instance_zone" {
  default = "us-central1-a"
  description = "The zone where instances will be created"
}

variable "instance_service_account" {
  default = ""
  description = "The service account under which the instances will be created"
}

variable "instance_root_disk_size" {
  default = "50"
  description = "default size of instance"
}

variable "instance_size" {
  default = "n1-standard-1"
  description = "default size of instance"
}

variable "instance_image" {
  default = "centos-7"
  description = "Image used to build instance"
}

variable "instance_docker_disk_size" {
  default = "50"
  description = "default size of docker volume"
}

variable "instance_docker_disk_type" {
  default = "pd-ssd"
  description = "default disk type for docker volume"
}

variable "instance_docker_disk_name" {
  default = "docker"
  description = "default disk type for docker volume"
}

variable "instance_network_name" {
  default = ""
  description = "The default network name to create instance"
}

variable "instance_subnetwork_name" {
  default = ""
  description = "The default subnetwork name to create instance"
}

variable "instance_scopes" {
  type    = list(string)
  description = "The default scopes for instance"
  default = [
    "userinfo-email", 
    "compute-ro", 
    "storage-ro", 
    "https://www.googleapis.com/auth/monitoring.write", 
    "logging-write" ]
}

variable "instance_tags" {
  type    = "list" 
  description = "The default tags for instance"
  default = [ ]
}

variable "instance_labels" {
  type    = "map" 
  description = "The default labels for instance"
  default = { }
}

variable "instance_stop_for_update" {
  default = "true"
  description = "The default is to allow stopping instance for updating"
}

variable "instance_metadata_script" {
  default = "centos-ansible.sh"
  description = "default metadata script"
}

# Data disk variables

variable "instance_data_disk_size" {
  default = "200"
  description = "default size of docker volume"
}

variable "instance_data_disk_type" {
  default = "pd-standard"
  description = "default disk type for docker volume"
}

variable "instance_data_disk_name" {
  default = "data"
  description = "default disk type for docker volume"
}

# Mongo variables

variable "mongodb_roles" {
  default = [
    "primary",
    "secondary",
    "arbiter"
  ]
  description = "host roles that will be present in this cluster"
}

variable "mongodb_host_port" {
  default = "{{if env "MONGODB_HOST_PORT"}}{{env "MONGODB_HOST_PORT"}}{{else}}27017{{end}}"
}

variable "mongodb_container_port" {
  default = "{{if env "MONGODB_CONTAINER_PORT"}}{{env "MONGODB_CONTAINER_PORT"}}{{else}}27017{{end}}"
}

variable "mongodb_data_path" {
  default = "{{if env "MONGODB_DATA_PATH"}}{{env "MONGODB_DATA_PATH"}}{{else}}/local/mongodb_data{{end}}"
}

variable "mongodb_app_username" {
  default = "{{if env "MONGODB_APP_USERNAME"}}{{env "MONGODB_APP_USERNAME"}}{{else}}{{env "SERVICE"}}{{end}}"
}

variable "mongodb_database" {
  default = "{{if env "MONGODB_DATABASE"}}{{env "MONGODB_DATABASE"}}{{else}}{{env "SERVICE"}}{{end}}"
}

resource "random_id" "mongodb-user-password" {
  byte_length   = 16
}

resource "random_id" "mongodb-root-password" {
  byte_length   = 16
}

resource "random_string" "mongodb-replica-set-key" {
  length = 16
  special = false
}

provider "vault" {}

resource "vault_generic_secret" "app-database-credentials" {
  path = "${var.vault_path_prefix}/${var.service}/secrets/mongo/app_user"

  data_json = <<EOT
{
  "username": "${var.mongodb_app_username}",
  "password": "${random_id.mongodb-user-password.hex}"
}
EOT
}

resource "vault_generic_secret" "root-database-credentials" {
  path = "${var.vault_path_prefix}/${var.service}/secrets/mongo/root_user"

  data_json = <<EOT
{
  "username": "root",
  "password": "${random_id.mongodb-root-password.hex}"
}
EOT
}

variable "roles" {
  default = ["username1", "username2"]
}