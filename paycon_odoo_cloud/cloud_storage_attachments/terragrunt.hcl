include {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  config_vars = read_terragrunt_config(find_in_parent_folders("secrets.hcl"))
}

terraform {
  source = "${get_repo_root()}/modules/cloud_storage"
}

inputs = {
  region      = local.config_vars.locals.region
  project_id  = local.config_vars.locals.project_id
  bucket_name = "paycon_attachments"
}
