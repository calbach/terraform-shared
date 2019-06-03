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
  type = list(object({
    name    = string
    type    = string
    rrdatas  = string
  }))
  default = [
    {
      name   = {}
      type = {}
      rrdatas = {}
    },
  ]
}
