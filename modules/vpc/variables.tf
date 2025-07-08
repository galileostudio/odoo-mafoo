variable "project_id" {
  type        = string
  description = "ID do projeto GCP onde os recursos serão criados."
  validation {
    condition     = length(var.project_id) > 0
    error_message = "O project_id não pode estar vazio."
  }
}

variable "region" {
  type        = string
  description = "Região onde os recursos serão criados."
  default     = "southamerica-east1"
  validation {
    condition = contains([
      "southamerica-east1"
    ], var.region)
    error_message = "Região deve ser uma das regiões suportadas."
  }
}

variable "vpc_name" {
  type        = string
  description = "Nome da VPC onde os recursos serão criados."
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.vpc_name))
    error_message = "Nome da VPC deve seguir as convenções do GCP."
  }
}

variable "subnet_name" {
  type        = string
  description = "Nome da sub-rede onde os recursos serão criados."
}

variable "subnet_cidr" {
  type        = string
  default     = "10.0.0.0/24"
  description = "CIDR da sub-rede onde os recursos serão criados."
  validation {
    condition     = can(cidrhost(var.subnet_cidr, 0))
    error_message = "subnet_cidr deve ser um CIDR válido."
  }
}

variable "delete_default_routes" {
  type        = bool
  default     = false
  description = "Se verdadeiro, remove as rotas padrão da VPC."
}

variable "create_default_route" {
  type        = bool
  default     = true
  description = "Se verdadeiro, cria uma rota padrão para a VPC."
}

variable "allowed_application_ports" {
  type        = list(string)
  default     = ["8069", "8071", "8072"]
  description = "Lista de portas permitidas para a aplicação."
  validation {
    condition     = length(var.allowed_application_ports) > 0
    error_message = "A lista de portas permitidas não pode estar vazia."
  }
}
