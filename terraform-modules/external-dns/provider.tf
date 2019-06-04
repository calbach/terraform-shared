terraform {
  required_version = ">= 0.12.0"
}

provider "google" {
    alias = "targetdns"
    credentials = "${var.target_credentials}"
    project = "${var.target_project}"
    region = "${var.region}"
}
