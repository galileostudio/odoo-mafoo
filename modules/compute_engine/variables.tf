variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "southamerica-east1"
}

variable "machine_type" {
  type = string
}

variable "service_account_email" {
  type = string
}

variable "subnet_self_link" {
  type = string
}

#variable "health_check_self_link" {
#  type = string
#}

variable "disk_type" {
  type = string
}

variable "initial_size" {
  type = number
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "cpu_target" {
  type = number
}

variable "disk_size_gb" {
  type = number
}

variable "attachments_bucket_name" {
  type        = string
  description = "Nome do bucket para attachments"
}

variable "plugins_bucket_name" {
  type        = string
  description = "Nome do bucket para plugins"
}

variable "db_host" {
  description = "IP privado do Cloud SQL"
  type        = string
}

variable "db_username" {
  type        = string
  description = "Database username for Odoo."
}

variable "db_password" {
  type        = string
  description = "Database password for Odoo."
}

variable "enviroment" {
  type        = string
  description = "Environment name (e.g., prod, dev, staging)."
}

variable "cost_center" {
  type = string
}

variable "application_name" {
  type        = string
  description = "Nome da aplicação, usado para prefixar recursos."
}

variable "allow_health_checks" {
  type        = bool
  default     = true
  description = "Permitir health checks no grupo de instâncias."
}

variable "allow_ssh" {
  type        = bool
  default     = true
  description = "Permitir acesso SSH às instâncias."
}

variable "additional_tags" {
  type        = list(string)
  default     = []
  description = "Tags adicionais para as instâncias."
}

variable "compute_image_project" {
  type        = string
  default     = "debian-cloud"
  description = "Projeto do GCP onde a imagem do Compute Engine está localizada."
}
variable "compute_image_family" {
  type        = string
  default     = "debian-12"
  description = "Família da imagem do Compute Engine."
}
variable "compute_name_prefix" {
  type        = string
  default     = "odoo-prod-template-"
  description = "Prefixo para o nome do template de instância."
}

variable "admin_password_override" {
  type        = string
  default     = ""
  description = "Senha do administrador da aplicação. Se não for fornecida, será gerada uma senha aleatória."
}

variable "odoo_version" {
  type        = string
  default     = "16.0"
  description = "Versão do Odoo a ser instalada."
}

variable "log_level" {
  type        = string
  default     = "info"
  description = "Nível de log para a aplicação."
}

variable "proxy_mode" {
  type        = bool
  default     = false
  description = "Habilitar modo proxy reverso."
}

variable "max_cron_threads" {
  type        = number
  default     = 2
  description = "Número máximo de threads cron para aplicação."
}

variable "workers" {
  type        = number
  default     = 2
  description = "Número de workers para a aplicação."
}

variable "additional_addons_paths" {
  type        = list(string)
  default     = []
  description = "Caminhos adicionais para addons personalizados."
}

variable "compute_group_manager" {
  type        = string
  default     = "odoo-prod-mig"
  description = "Nome do gerenciador de grupos de instâncias."
}

variable "base_instance_name" {
  type        = string
  default     = "odoo-prod-instance"
  description = "Nome base para as instâncias do Compute Engine."
}

variable "compute_autoscaler_name" {
  type        = string
  default     = "odoo-prod-autoscaler"
  description = "Nome do autoscaler para o grupo de instâncias."
}

variable "compute_named_port" {
  type        = number
  default     = 8069
  description = "Porta nomeada para o grupo de instâncias."
}
