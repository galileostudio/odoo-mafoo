locals {
  config_vars = read_terragrunt_config(find_in_parent_folders("secrets.hcl"))
}

remote_state {
  backend = "gcs"
  config = {
    bucket   = "${local.config_vars.locals.remote_state_bucket}"
    prefix   = "${path_relative_to_include()}/terraform.tfstate"
    project  = "${local.config_vars.locals.project_id}"
    location = "${local.config_vars.locals.region}"
  }
}

inputs = {
  application_name = "odoo"
  enviroment       = "prod"

  region     = local.config_vars.locals.region
  project_id = local.config_vars.locals.project_id
}

terraform {
  before_hook "before_hook" {
    commands = ["apply", "plan", "destroy"]
    execute  = ["echo", "Executando módulo: ${path_relative_to_include()}"]
  }

  after_hook "after_hook" {
    commands = ["apply", "plan", "destroy"]
    execute  = ["echo", "Módulo concluído: ${path_relative_to_include()}"]
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    provider "google" {
      project = "${local.config_vars.locals.project_id}"
      region  = "${local.config_vars.locals.region}"
    }
    provider "google-beta" {
      project = "${local.config_vars.locals.project_id}"
      region  = "${local.config_vars.locals.region}"
    }
  EOF
}
