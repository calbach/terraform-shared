/*
* Kubernetes Cluster
*/

resource "google_container_cluster" "cluster" {
  name       = var.cluster_name
  location   = var.location
  depends_on = [var.dependencies]

  network    = var.cluster_network
  subnetwork = var.cluster_subnetwork

  # CIS compliance: stackdriver logging
  logging_service = var.use_new_stackdriver_apis ? "logging.googleapis.com/kubernetes" : "logging.googleapis.com"

  # CIS compliance: stackdriver monitoring
  monitoring_service = var.use_new_stackdriver_apis ? "monitoring.googleapis.com/kubernetes" : "monitoring.googleapis.com"

  min_master_version = var.k8s_version

  lifecycle {
    ignore_changes = [
      node_pool,
      master_auth[0].client_certificate_config[0].issue_client_certificate,
      network,
      subnetwork,
    ]
  }

  # Silly, but necessary to have a default pool of 0 nodes. This allows the node definition to be handled cleanly
  # in a separate file
  remove_default_node_pool = true
  initial_node_count = 1

  # CIS compliance: disable legacy Auth
  enable_legacy_abac = false

  # CIS compliance: disable basic auth -- this creates a certificate and
  # disables basic auth by not specifying a user / pasword.
  # See https://www.terraform.io/docs/providers/google/r/container_cluster.html#master_auth
  master_auth {
    client_certificate_config {
      issue_client_certificate = true
    }
    username = ""
    password = ""
  }

  # CIS compliance: Enable Network Policy
  network_policy {
    enabled = true
  }

  ip_allocation_policy = [{
    # CIS compliance: Enable Alias IP Ranges.
    use_ip_aliases = true
    # According to trial and error, setting these values to null
    # lets Google derive values that actually work.
    # Otherwise you'll end up flipping a table trying to set things manually.
    create_subnetwork             = null
    cluster_ipv4_cidr_block       = null
    cluster_secondary_range_name  = null
    node_ipv4_cidr_block          = null
    services_ipv4_cidr_block      = null
    services_secondary_range_name = null
    subnetwork_name               = null
  }]

  # CIS compliance: Enable PodSecurityPolicyController
  pod_security_policy_config {
    enabled = true
  }

  # OMISSION: CIS compliance: Enable Private Cluster
  private_cluster_config {
    enable_private_endpoint = var.enable_private_endpoint
    enable_private_nodes = var.enable_private_nodes
    master_ipv4_cidr_block = var.private_master_ipv4_cidr_block
  }

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.master_authorized_network_cidrs
      content {
        cidr_block = cidr_blocks.value
      }
    }
  }

  addons_config {
    kubernetes_dashboard {
      # CIS compliance: Disable dashboard
      disabled = true
    }

    network_policy_config {
      disabled = false
    }
  }
}
