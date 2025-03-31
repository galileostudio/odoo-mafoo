include {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../modules/vpc"
}

inputs = {
  region      = include.locals.region
  project_id  = include.locals.project_id
  vpc_name    = "paycon-vpc"
  subnet_name = "paycon-subnet"
  subnet_cidr = "10.0.0.0/24"

}
