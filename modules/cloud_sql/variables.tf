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
  type    = string
  default = "odoodb"
}

variable "db_username" {
  type    = string
  default = "odoo"
}

variable "db_password" {
  type    = string
  default = "change_me"
}
