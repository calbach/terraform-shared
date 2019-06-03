# google project
variable "target_project" {}
#region
variable "region" {}
#credentials
variable "target_credentials" {}
#depends_on work around
variable "depends_on" { default = [], type = "list" }
#name of external dns_zone resource name
variable "target_dns_resource_name" {}
#name of external dns_zone name
variable "target_dns_zone_name" {}
variable "record" {
  default = [
    {
      name   = {}
      type = {}
      rrdata = { default = [], type = "list" }
    },
  ]
}
