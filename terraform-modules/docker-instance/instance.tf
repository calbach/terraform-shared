#
# Instance cluster
#

# pub IP
resource "google_compute_address" "instance-public-ip" {
  provider                = "google.target"
  count = "${var.enable_flag == "1"?var.instance_num_hosts:0}"
  name = "${format("%s-%02d", var.instance_name, count.index+1)}"
  region = "${var.instance_region}"
}

# instance scratch - docker disk
resource "google_compute_disk" "instance-docker-disk" {
  provider                = "google.target"
  count = "${var.enable_flag == "1"?var.instance_num_hosts:0}"
  name = "${format("%s-%02d-docker-disk", var.instance_name, count.index+1)}"
  size = "${var.instance_docker_disk_size}"
  type = "${var.instance_docker_disk_type}"
  zone = "${var.instance_zone}"
}

# GCE instance
resource "google_compute_instance" "instance" {
    provider                = "google.target"
  name = "${format("%s-%02d", var.instance_name, count.index+1)}"
  count = "${var.enable_flag == "1"?var.instance_num_hosts:0}"
  machine_type = "${var.instance_size}"
  zone = "${var.instance_zone}"
  depends_on = [ "google_compute_address.instance-public-ip", "google_compute_disk.instance-docker-disk" ]

  tags =  "${var.instance_tags}" 

  labels = "${var.instance_labels}" 

  # Local OS disk
  boot_disk {
    auto_delete = true
    initialize_params {
      image = "${var.instance_image}"
      size = "${var.instance_root_disk_size}"
    }
  }

  # Docker disk
  attached_disk {
    source = "${element(google_compute_disk.instance-docker-disk.*.name, count.index)}"
    device_name = "${var.instance_docker_disk_name}"
  }

  lifecycle {
    prevent_destroy = false
  }

  allow_stopping_for_update = "${var.instance_stop_for_update}"

  network_interface {
    network    = "${var.instance_network_name}"
    subnetwork = "${var.instance_subnetwork_name == "" ? var.instance_network_name : var.instance_subnetwork_name}"
    access_config {
      nat_ip = "${element(google_compute_address.instance-public-ip.*.address, count.index)}"
    }
  }

  metadata_startup_script = "${file("${path.module}/${var.instance_metadata_script}")}"

  service_account {
    scopes = "${var.instance_scopes}"
    email = "${var.instance_service_account}"
  }
}

