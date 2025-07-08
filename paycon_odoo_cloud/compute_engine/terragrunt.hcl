include {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  config_vars = read_terragrunt_config(find_in_parent_folders("secrets.hcl"))
}

terraform {
  source = "${get_repo_root()}/modules/compute_engine"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_output = "mock-vpc-output"
    subnet_self_link    = "https://mock-vpc-self-link/projects/team:myproject/global/networks/backend-network"
  }
}

#dependency "cloud_storage_plugins" {
#  config_path = "../cloud_storage_plugins"
#  mock_outputs = {
#    bucket_name = "mock-plugins-bucket"
#  }
#}
#
dependency "paycon_attachments" {
  config_path = "../cloud_storage_attachments"
  mock_outputs = {
    bucket_name = "mock-attachments-bucket"
  }
}

dependency "cloud_sql" {
  config_path = "../cloud_sql"

  mock_outputs = {
    db_name     = "mock-cloud_sql-output"
    db_password = "mock-cloud_sql-password"
    db_username = "mock-cloud_sql-username"
    db_host     = "mock-cloud_sql-host"
    private_ip  = "mock-cloud_sql-private_ip"
  }
}


dependency "health_checks" {
  config_path = "../health_checks"
  mock_outputs = {
    health_check_self_link = "mock-health-check"
  }
}


inputs = {
  attachments_bucket_name = dependency.paycon_attachments.outputs.bucket_name
  cost_center             = "all"
  db_host                 = dependency.cloud_sql.outputs.private_ip
  db_password             = dependency.cloud_sql.outputs.db_password
  db_username             = dependency.cloud_sql.outputs.db_username
  db_name                 = dependency.cloud_sql.outputs.db_name
  plugins_bucket_name     = 123
  additional_addons_paths = ["/tmp", "/tmp/plugins"]

  # Configurações de rede
  subnet_self_link = dependency.vpc.outputs.subnet_self_link

  # Configurações de auto-scaling
  initial_size = 1
  min_size     = 1
  max_size     = 4
  cpu_target   = 0.75

  # Service account
  service_account_email = local.config_vars.locals.service_account_email

  # Buckets GCS
  #plugins_bucket_name     = dependency.cloud_storage_plugins.outputs.bucket_name
  #attachments_bucket_name = dependency.paycon_attachments.outputs.bucket_name

  # Configuração adicional para produção
  machine_type           = "e2-standard-2"
  disk_size_gb           = 25
  disk_type              = "pd-ssd"
  health_check_self_link = dependency.health_checks.outputs.health_check_self_link
}
