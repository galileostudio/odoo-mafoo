variable "project_id" {
  type = string
  validation {
    condition = length(var.project_id) > 0
    error_message = "O project_id não pode estar vazio."
  }
}

variable "region" {
  type = string
  validation {
    condition = contains([
      "southamerica-east1"
    ], var.region)
    error_message = "Região deve ser uma das regiões suportadas."
  }
}

variable "vpc_name" {
  type = string
  validation {
    condition = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.vpc_name))
    error_message = "Nome da VPC deve seguir as convenções do GCP."
  }
}

variable "subnet_name" {
  type = string
}

variable "subnet_cidr" {
  type    = string
  default = "10.0.0.0/24"
  validation {
    condition = can(cidrhost(var.subnet_cidr, 0))
    error_message = "subnet_cidr deve ser um CIDR válido."
  }
}

variable "delete_default_routes" {
  type    = bool
  default = false
}

variable "create_default_route" {
  type        = bool
  default     = true
}