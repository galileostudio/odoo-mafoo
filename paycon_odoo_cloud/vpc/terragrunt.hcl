include {
  path = find_in_parent_folders("root.hcl")
  expose = true
}
locals {
  config_vars = read_terragrunt_config(find_in_parent_folders("secrets.hcl"))
}
terraform {
  source = "${get_parent_terragrunt_dir()}/modules/vpc"
}

inputs = {
  region      = local.config_vars.locals.region
  project_id  = local.config_vars.locals.project_id
  vpc_name    = local.config_vars.locals.vpc_name
  subnet_name = local.config_vars.locals.vpc_subnet_name
  subnet_cidr = local.config_vars.locals.vpc_subnet_cidr
}
