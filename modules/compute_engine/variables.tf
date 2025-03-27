variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "southamerica-east1"
}

variable "machine_type" {
  type    = string
  default = "e2-medium"
}

variable "custom_image" {
  type = string
  # Exemplo: "projects/meu-projeto-gcp/global/images/odoo-17-custom-image"
}

variable "service_account_email" {
  type = string
}

variable "subnet_self_link" {
  type = string
}

variable "health_check_self_link" {
  type = string
}

variable "initial_size" {
  type    = number
  default = 1
}

variable "min_size" {
  type    = number
  default = 1
}

variable "max_size" {
  type    = number
  default = 5
}

variable "cpu_target" {
  type    = number
  default = 0.75
}

# Novas variáveis para os buckets
variable "plugins_bucket_name" {
  type = string
}

variable "attachments_bucket_name" {
  type = string
}

variable "db_host" {
  description = "IP privado do Cloud SQL"
  type        = string
}
