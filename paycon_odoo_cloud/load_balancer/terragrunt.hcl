# terragrunt.hcl para o ambiente prod, componente load_balancer.
include {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../modules/load_balancer"
}

dependency "compute_engine" {
  config_path = "../compute_engine"

  mock_outputs = {
    mig_self_link            = "mock-mig"
    health_check_self_link   = "mock-health-check"
    instance_group_self_link = "placeholder-instance-group"
  }
}


dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    subnet_self_link = "mock-subnet-self-link"
  }
}

# Exemplo de inputs (ajuste conforme sua necessidade):
inputs = {
  region                 = include.locals.region
  project_id             = include.locals.project_id
  mig_self_link          = dependency.compute_engine.outputs.mig_self_link
  health_check_self_link = dependency.compute_engine.outputs.health_check_self_link
  ssl_domains            = ["galileostdio.com"]
  enable_cdn             = false
}