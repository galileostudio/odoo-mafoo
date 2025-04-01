include {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../modules/health_checks"
}

inputs = {
  project_id = include.locals.project_id
  region     = include.locals.region
}