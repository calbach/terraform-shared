/*
* Node Pool
*/

resource "google_container_node_pool" "node-pool" {
  provider            = "google"
  depends_on  = [
    "google_container_cluster.cluster"
  ]
  name        = "${var.cluster_name}-np"
  zone        = "${var.zone}"
  cluster     = "${google_container_cluster.cluster.name}"
  node_count  = "${var.node_pool_count}"

  management {
    # CIS compliance: enable automatic repair
    auto_repair = true
    # CIS compliance: enable automatic upgrade
    auto_upgrade = true
  }

  version = "${var.node_version}"

  node_config {
    # CIS compliance: COS image
    image_type      = "COS"
    machine_type    = "${var.node_pool_machine_type}"
    disk_size_gb    = "${var.node_pool_disk_size_gb}"

    oauth_scopes    = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}
