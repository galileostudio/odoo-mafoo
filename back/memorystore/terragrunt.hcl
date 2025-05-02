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
    vpc_self_link = "projects/paycon-454222/global/networks/paycon-vpc"
  }
}


inputs = {
  region          = include.locals.region
  project_id      = include.locals.project_id
  vpc_self_link   = dependency.vpc.outputs.vpc_self_link
}
