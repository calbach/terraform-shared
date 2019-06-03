data "google_dns_managed_zone" "dns_zone" {
    provider     = "google.targetdns"
    project      = "${var.target_project}"
    name         = "${var.target_dns_zone_name}"
}
resource "google_dns_record_set" "set-record" {
  provider     = "google.targetdns"
  managed_zone = "${data.google_dns_managed_zone.dns_zone.name}"
#  name         = "${var.a_record_name}.${data.google_dns_managed_zone.${var.target_dns_resource_name}.dns_name}"
#  type         = "A"
  ttl          = "300"
#  rrdatas      = "${var.rrdatas_list_a_record}"

  dynamic "record" {
    for_each = [for s in record: {
      name   = s.name
      type   = s.type
      rrdatas = s.rrdatas
    }]
    content {
      name     = record.value.name
      type     = record.value.type
      rrdatas  = record.value.rrdatas
    }
  }
}


#resource "google_dns_record_set" "set-cname-record" {
#    provider = "google.targetdns"
#    managed_zone = "${data.google_dns_managed_zone.${var.target_dns_resource_name}.name}"
#    name = "${var.cname_record_name}.${data.google_dns_managed_zone.${var.target_dns_resource_name}.dns_name}"
#    type = "CNAME"
#    ttl = "300"
#    rrdatas = "${var.rrdatas_list_cname_record}"
#}
