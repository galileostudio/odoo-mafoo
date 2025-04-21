include {
  path = find_in_parent_folders("root.hcl")
  expose = true
}

terraform {
  source = "../../modules/compute_engine"
}

# Dependências obrigatórias
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
    db_username = "odoo"       # Adicione mock para testes
    db_password = "change_me"  # Adicione mock para testes
 
  }
}


dependency "health_checks" {
  config_path = "../health_checks"
  mock_outputs = {
    health_check_self_link = "mock-health-check"
  }
}

inputs = {
  region                  = include.locals.region
  project_id              = include.locals.project_id
  
  # Configurações de rede
  subnet_self_link        = dependency.vpc.outputs.subnet_self_link
  
  # Configurações de auto-scaling
  initial_size            = 1
  min_size                = 1
  max_size                = 5
  cpu_target              = 0.75
  
  # Service account
  service_account_email   = "the-ring@paycon-454222.iam.gserviceaccount.com"
  
  # Conexões com outros serviços
  db_host                 = dependency.cloud_sql.outputs.private_ip
  db_username             = dependency.cloud_sql.outputs.db_username
  db_password             = dependency.cloud_sql.outputs.db_password
  cache_private_ip        = dependency.memorystore.outputs.private_ip
  
  # Buckets GCS
  plugins_bucket_name     = dependency.paycon_plugins.outputs.bucket_name
  attachments_bucket_name = dependency.paycon_attachments.outputs.bucket_name
  
  # Configuração adicional para produção
  machine_type            = "n1-standard-2"
  disk_size_gb            = 20
  disk_type               = "pd-ssd"
  health_check_self_link = dependency.health_checks.outputs.health_check_self_link

}