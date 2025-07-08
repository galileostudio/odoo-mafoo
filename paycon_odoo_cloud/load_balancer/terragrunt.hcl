include {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  config_vars = read_terragrunt_config(find_in_parent_folders("secrets.hcl"))
}

terraform {
  source = "${get_repo_root()}/modules/load_balancer"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    subnet_self_link = "mock-subnet-self-link"
    vpc_name         = "mock-vpc-name"
    vpc_self_link    = "mock-vpc-self-link"
    subnet_name      = "mock-subnet-name"
  }
}

dependency "health_checks" {
  config_path = "../health_checks"
  mock_outputs = {
    health_check_self_link = "mock-health-check"
  }
}

dependency "compute_engine" {
  config_path = "../compute_engine"

  mock_outputs = {
    mig_self_link            = "mock-mig"
    health_check_self_link   = "mock-health-check"
    instance_group_self_link = "placeholder-instance-group"
  }
}


inputs = {
  vpc_name         = dependency.vpc.outputs.vpc_name
  vpc_self_link    = dependency.vpc.outputs.vpc_self_link
  subnet_self_link = dependency.vpc.outputs.subnet_self_link

  # Managed Instance Group
  mig_self_link            = dependency.compute_engine.outputs.mig_self_link
  instance_group_self_link = dependency.compute_engine.outputs.instance_group_self_link

  # Health check
  health_check_self_link = dependency.health_checks.outputs.health_check_self_link

  # SSL
  ssl_domains = ["odoo.galileostdio.com"]
  enable_cdn  = false
}

