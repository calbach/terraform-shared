resource "google_bigquery_dataset" "logs" {
  dataset_id                  = "${replace(var.project, "-", "_")}_${var.application_name}_${var.owner}_audit${var.nonce != "" ? "_${var.nonce}" : ""}"
  description                 = "Audit logs for ${var.application_name} for ${var.owner}"
  location                    = "US"
  // 31 days in ms
  default_table_expiration_ms = "${var.bigquery_retention_days * 24 * 60 * 60 * 1000}"

  labels = {
    env = "${var.owner}"
  }
  access {
    role           = "OWNER"
    special_group = "projectOwners"
  }
  access {
    role           = "WRITER"
    user_by_email = "${element(split(":", google_logging_project_sink.bigquery-log-sink.writer_identity), 1)}"
  }
}

resource "google_logging_project_sink" "bigquery-log-sink" {
    name = "${var.application_name}-${var.owner}-bigquery-log-sink${var.nonce != "" ? "_${var.nonce}" : ""}"
    destination = "bigquery.googleapis.com/projects/${var.project}/datasets/${replace(var.project, "-", "_")}_${var.application_name}_${var.owner}_audit"
    filter = "${var.log_filter}"
    unique_writer_identity = true
}

resource "google_storage_bucket" "logs" {
    name     = "${var.project}_${var.application_name}_${var.owner}_audit${var.nonce != "" ? "_${var.nonce}" : ""}"
}

# Grant service account access to the storage bucket
resource "google_storage_bucket_iam_member" "bucket-log-writer" {
  bucket = "${google_storage_bucket.logs.name}"
  role   = "roles/storage.objectCreator"
  member = "${google_logging_project_sink.bucket-log-sink.writer_identity}"
}

resource "google_logging_project_sink" "bucket-log-sink" {
    name = "${var.application_name}-${var.owner}-gcs-log-sink${var.nonce != "" ? "_${var.nonce}" : ""}"
    destination = "storage.googleapis.com/${google_storage_bucket.logs.name}"
    filter = "${var.log_filter}"
    unique_writer_identity = true
}
