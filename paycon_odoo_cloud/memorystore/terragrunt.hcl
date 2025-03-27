include {
  path = find_in_parent_folders("../root.hcl")
  expose = true
}

terraform {
  source = "../../modules/memorystore"
}

dependency "vpc" {
  config_path = "../vpc"

  mock_outputs = {
    vpc_self_link = "projects/mock-project/global/networks/mock-vpc"
  }
}
# Exemplo de inputs (ajuste conforme sua necessidade):
inputs = {
  region          = include.locals.region
  project_id      = include.locals.region
  vpc_self_link   = dependency.vpc.outputs.vpc_self_link
}
