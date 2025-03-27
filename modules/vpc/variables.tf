variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "southamerica-east1"
}

variable "vpc_name" {
  type    = string
  default = "prod-vpc"
}

variable "subnet_name" {
  type    = string
  default = "prod-subnet"
}

variable "subnet_cidr" {
  type    = string
  default = "10.0.0.0/24"
}
