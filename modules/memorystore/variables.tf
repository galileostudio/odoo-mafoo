variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "southamerica-east1"
}

variable "redis_name" {
  type    = string
  default = "odoo-redis"
}

variable "vpc_self_link" {
  type = string
}

variable "memory_size_gb" {
  type    = number
  default = 1
}
