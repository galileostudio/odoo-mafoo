variable "project_id" {
  type = string
  description = "ID do projeto GCP onde os recursos serão criados."
}

variable "bucket_name" {
  type = string
  description = "Nome do bucket de armazenamento."
}

variable "region" {
  type    = string
  default = "southamerica-east1"
  description = "Região onde o bucket será criado."
}
