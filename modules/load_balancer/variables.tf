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

variable "instance_group_self_link" {
  description = "Self-link do instance group (não do manager)"
  type        = string
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
variable "health_check_port" {
  type        = number
  default     = 8069
  description = "Porta do health check do load balancer"
}

variable "application_name" {
  type        = string
  description = "Nome da aplicação, usado para prefixar recursos."
}
