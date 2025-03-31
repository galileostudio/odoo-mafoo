include {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../modules/cloud_storage"
}


inputs = {
  region      = include.locals.region
  project_id  = include.locals.project_id
  bucket_name = "paycon_plugins"
}