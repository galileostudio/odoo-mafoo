include {
  path   = find_in_parent_folders("root.hcl")
  expose = true
}

locals {
  config_vars = read_terragrunt_config(find_in_parent_folders("secrets.hcl"))
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules/compute_engine"
}

# Dependências obrigatórias
dependency "vpc" {
  config_path = "../vpc"
}

#dependency "cloud_storage_plugins" {
#  config_path = "../cloud_storage_plugins"
#  mock_outputs = {
#    bucket_name = "mock-plugins-bucket"
#  }
#}
#
#dependency "paycon_attachments" {
#  config_path = "../cloud_storage_attachments"
#  mock_outputs = {
#    bucket_name = "mock-attachments-bucket"
#  }
#}

#dependency "cloud_sql" {
#  config_path = "../cloud_sql"
#  mock_outputs = {
#    private_ip = "10.0.0.1"
#    db_username = "odoo"       # Adicione mock para testes
#    db_password = "change_me"  # Adicione mock para testes
#  }
#}


#dependency "health_checks" {
#  config_path = "../health_checks"
#  mock_outputs = {
#    health_check_self_link = "mock-health-check"
#  }
#}


inputs = {
  application_name = "odoo"
  enviroment       = "prod"

  attachments_bucket_name = "aa"
  cost_center             = "all"
  db_host                 = 123
  db_password             = 123
  db_username             = "as"
  plugins_bucket_name     = 123
  additional_addons_paths = ["/tmp", "/tmp/plugins"]

  region     = local.config_vars.locals.region
  project_id = local.config_vars.locals.project_id

  # Configurações de rede
  subnet_self_link = dependency.vpc.outputs.subnet_self_link

  # Configurações de auto-scaling
  initial_size = 1
  min_size     = 1
  max_size     = 5
  cpu_target   = 0.75

  # Service account
  service_account_email = local.config_vars.locals.service_account_email

  # Buckets GCS
  #plugins_bucket_name     = dependency.cloud_storage_plugins.outputs.bucket_name
  #attachments_bucket_name = dependency.paycon_attachments.outputs.bucket_name

  # Configuração adicional para produção
  machine_type = local.config_vars.locals.machine_type
  disk_size_gb = local.config_vars.locals.disk_size_gb
  disk_type    = local.config_vars.locals.disk_type
  # health_check_self_link = dependency.health_checks.outputs.health_check_self_link
}
