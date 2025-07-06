variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "health_check_name" {
  type = string
}

variable "health_check_port" {
  type    = number
  default = 8069
}

variable "health_check_path" {
  type    = string
  default = "/web/database/selector"
}
variable "health_check_interval_sec" {
  type    = number
  default = 60
}

variable "application_name" {
  type        = string
  description = "Nome da aplicação, usado para prefixar recursos."
}
