variable "project_id" {
  type        = string
  description = "Valor do ID do projeto GCP onde os recursos serão criados."
}

variable "region" {
  type        = string
  description = "Valor da região onde os recursos serão criados."
}
variable "health_check_name" {
  type        = string
  description = "Nome do health check."
}

variable "health_check_port" {
  type        = number
  default     = 8069
  description = "Porta do health check."
}

variable "health_check_path" {
  type        = string
  default     = "/web/database/selector"
  description = "Caminho do health check."
}
variable "health_check_interval_sec" {
  type        = number
  default     = 60
  description = "Intervalo entre verificações de saúde."
}

variable "application_name" {
  type        = string
  description = "Nome da aplicação, usado para prefixar recursos."
}
