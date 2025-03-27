include {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../modules/compute_engine"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    subnet_self_link = "mock-subnet-self-link"
  }
}

dependency "paycon_plugins" {
  config_path = "../cloud_storage_plugins"
  mock_outputs = {
    bucket_name = "mock-plugins-bucket"
  }
}

dependency "paycon_attachments" {
  config_path = "../cloud_storage_attachments"
  mock_outputs = {
    bucket_name = "mock-attachments-bucket"
  }
}

dependency "memorystore" {
  config_path = "../memorystore"
  mock_outputs = {
    private_ip = "0.0.0.0"
  }
}

dependency "cloud_sql" {
  config_path = "../cloud_sql"
  mock_outputs = {
    private_ip = "10.0.0.1"
  }
}

inputs = {
  region                  = include.locals.region
  project_id              = include.locals.region
  custom_image            = "projects/paycon-454222/global/images/odoo-17-custom-image"
  service_account_email   = "the-ring@paycon-454222.iam.gserviceaccount.com"
  subnet_self_link        = dependency.vpc.outputs.subnet_self_link
  health_check_self_link  = "insira-o-link-do-health-check"
  initial_size            = 1
  min_size                = 1
  max_size                = 5
  cpu_target              = 0.75
  plugins_bucket_name     = dependency.paycon_plugins.outputs.bucket_name
  attachments_bucket_name = dependency.paycon_attachments.outputs.bucket_name
  db_host                 = dependency.cloud_sql.outputs.private_ip
  cache_private_ip        = dependency.memorystore.outputs.private_ip
}
