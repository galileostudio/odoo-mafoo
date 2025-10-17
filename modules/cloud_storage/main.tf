terraform {
  backend "gcs" {}
}

resource "google_storage_bucket" "storage_bucket" {
  name          = var.bucket_name
  project       = var.project_id
  location      = var.region
  force_destroy = false

  versioning {
    enabled = true
  }
}
