data "google_dns_managed_zone" "dns_zone" {
    provider     = "google.targetdns"
    project      = "${var.target_project}"
    name         = "${var.target_dns_zone_name}"
}

resource "google_dns_record_set" "set_dns_record" {
  provider     = "google.broad-jade"
  ttl          = "300"
  managed_zone = "${data.google_dns_managed_zone.dns_zone.name}"
  dynamic "set_record" {
    for_each = [for record in var.records : {
      name = record.name
      type = record.type
      rrdata = record.rrdata
    }]

    content {
      name = set_record.value.name
      type = set_record.value.type
      rrdatas = set_record.value.rrdatas
    }
  }
}
