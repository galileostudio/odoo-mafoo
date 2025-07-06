variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "instance_name" {
  type    = string
  default = "odoo-postgres"
}

variable "tier" {
  type    = string
  default = "db-f1-micro"
}

variable "vpc_self_link" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "database_version" {
  type    = string
  default = "POSTGRES_14"
}

variable "application_name" {
  type        = string
  description = "Nome da aplicação, usado para prefixar recursos."
}

variable "enviroment" {
  type = string
}
