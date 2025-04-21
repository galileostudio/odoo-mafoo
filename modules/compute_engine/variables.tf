variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "southamerica-east1"
}

variable "machine_type" {
  type    = string
  default = "f1-micro"
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

variable "disk_type" {
  type    = string
  default = "pd-ssd"
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

variable "disk_size_gb" {
  type    = number
  default = 20
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
