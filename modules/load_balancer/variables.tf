variable "project_id" {
  type = string
}
variable "region" {
  type = string
}


variable "mig_self_link" {
  type = string
}

variable "enable_cdn" {
  type    = bool
  default = false
}

variable "ssl_domains" {
  type    = list(string)
  default = ["exemplo.com"]
}

