provider "google" {
    alias = "targetdns"
    credentials = "${var.target_credentials}"
    project = "${var.target_project}"
    region = "${var.region}"
    version = "1.20"
}
