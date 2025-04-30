# terragrunt.hcl para o ambiente prod, componente load_balancer.
include {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../modules/load_balancer"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    subnet_self_link = "mock-subnet-self-link"
    vpc_name = "mock-vpc-name"
    vpc_self_link = "mock-vpc-self-link"
    subnet_name = "mock-subnet-name"
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

# Exemplo de inputs (ajuste conforme sua necessidade):
# inputs = {

#   mig_self_link          = dependency.compute_engine.outputs.mig_self_link
#   health_check_self_link = dependency.health_checks.outputs.health_check_self_link
#   ssl_domains            = ["galileostdio.com"]
#   enable_cdn             = false

  
# }

inputs = {
  project_id               = include.locals.project_id
  region                   = include.locals.region

  # VPC/subnet (se o módulo usar)
  vpc_name                 = dependency.vpc.outputs.vpc_name
  vpc_self_link            = dependency.vpc.outputs.vpc_self_link
  subnet_self_link         = dependency.vpc.outputs.subnet_self_link

  # Managed Instance Group
  mig_self_link            = dependency.compute_engine.outputs.mig_self_link
  instance_group_self_link = dependency.compute_engine.outputs.instance_group_self_link

  # Health check
  health_check_self_link   = dependency.health_checks.outputs.health_check_self_link

  # SSL
  ssl_domains              = ["galileostudio.com"]
  enable_cdn               = false
}

