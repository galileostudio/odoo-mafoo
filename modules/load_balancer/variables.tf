variable "project_id" {
  type        = string
  description = "ID do projeto GCP"
}

variable "region" {
  type        = string
  description = "Região GCP onde os recursos serão criados"
}

variable "vpc_name" {
  type        = string
  description = "Nome da VPC onde o firewall será aplicado"
}

variable "mig_self_link" {
  type        = string
  description = "Self link do Managed Instance Group"
}

variable "enable_cdn" {
  type        = bool
  default     = false
  description = "Habilita CDN no load balancer"
}

variable "ssl_domains" {
  type        = list(string)
  default     = ["exemplo.com"]
  description = "Lista de domínios para o certificado SSL"
}

variable "health_check_self_link" {
  type        = string
  description = "Self link do health check criado no módulo health_checks"
}