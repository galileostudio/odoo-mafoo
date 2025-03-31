variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "southamerica-east1"
}

variable "vpc_name" {
  type    = string
  default = "paycon-vpc"
}

variable "subnet_name" {
  type    = string
  default = "paycon-subnet"
}

variable "subnet_cidr" {
  type    = string
  default = "10.0.0.0/24"
}
