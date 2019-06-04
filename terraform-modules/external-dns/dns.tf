terraform {
  required_version = ">= 0.12.0"
}

data "google_dns_managed_zone" "dns_zone" {
    provider     = "google.targetdns"
    project      = "${var.target_project}"
    name         = "${var.target_dns_zone_name}"
}

resource "google_dns_record_set" "set_dns_record" {
  dynamic "set_record" {
    for_each = [for record in var.records : {
      name = record.name
      type = record.type
      rrdatas = record.rrdatas
    }]

    content {
      name = set_record.value.name
      type = set_record.value.type
      rrdatas = set_record.value.rrdatas
    }
  }
  provider     = "google.broad-jade"
  ttl          = "300"
  managed_zone = "${data.google_dns_managed_zone.dns_zone.name}"
}
