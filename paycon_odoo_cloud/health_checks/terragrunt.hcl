include {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "${get_repo_root()}/modules/health_checks"
}


locals {
  config_vars = read_terragrunt_config(find_in_parent_folders("secrets.hcl"))
}


inputs = {
  project_id = local.config_vars.locals.project_id
  region     = local.config_vars.locals.region
}
