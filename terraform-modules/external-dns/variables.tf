# google project
variable "target_project" {}
#region
variable "region" {}
#credentials
variable "target_credentials" {}
#name of external dns_zone resource name
variable "target_dns_resource_name" {}
#name of external dns_zone name
variable "target_dns_zone_name" {}
variable "records" {
  default = [
    {
      name   = {}
      type = {}
      rrdatas = {}
    }
  ]
}
