locals {
  project_id = "master-462418"
  region     = "southamerica-east1"
}

remote_state {
  backend = "gcs"
  config = {
    bucket   = "paycongrunt"
    prefix   = "${path_relative_to_include()}/terraform.tfstate"
    project  = local.project_id
    location = local.region
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "google" {
      project = var.project_id
      region  = var.region
    }
    provider "google-beta" {
      project = var.project_id
      region  = var.region
    }
  EOF
}
