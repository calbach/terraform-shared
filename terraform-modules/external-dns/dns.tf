data "google_dns_managed_zone" "dns_zone" {
    provider     = "google.targetdns"
    project      = "${var.target_project}"
    name         = "${var.target_dns_zone_name}"
}

resource "google_dns_record_set" "set-record" {
  for_each = var.record
  dynamic "record" {
    for_each = [for s in record: {
      record_name   = s.name
      record_type   = s.type
      record_rrdatas = s.rrdatas
    }]
    content {
      name     = record.value.record_name
      type     = record.value.record_type
      rrdatas  = record.value.record_rrdatas


    }
  }
      provider     = "google.targetdns"
      managed_zone = "${data.google_dns_managed_zone.dns_zone.name}"
      ttl          = "300"
}


#resource "google_dns_record_set" "set-cname-record" {
#    provider = "google.targetdns"
#    managed_zone = "${data.google_dns_managed_zone.${var.target_dns_resource_name}.name}"
#    name = "${var.cname_record_name}.${data.google_dns_managed_zone.${var.target_dns_resource_name}.dns_name}"
#    type = "CNAME"
#    ttl = "300"
#    rrdatas = "${var.rrdatas_list_cname_record}"
#}
