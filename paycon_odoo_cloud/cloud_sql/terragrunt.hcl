include {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}


locals {
  config_vars = read_terragrunt_config(find_in_parent_folders("secrets.hcl"))
}

terraform {
  source = "${get_repo_root()}/modules/cloud_sql"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_self_link = "https://mock-vpc-self-link/projects/team:myproject/global/networks/backend-network"
  }
}


inputs = {
  vpc_self_link = dependency.vpc.outputs.vpc_self_link
  db_password   = local.config_vars.locals.db_password
  db_username   = local.config_vars.locals.db_username
  db_name       = "odoo"
}
