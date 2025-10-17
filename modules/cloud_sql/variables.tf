variable "project_id" {
  type        = string
  description = "Valor do ID do projeto GCP onde os recursos serão criados."
}

variable "region" {
  type        = string
  description = "Valor da região onde os recursos serão criados."
}

variable "instance_name" {
  type        = string
  default     = "database"
  description = "Nome da instância do Cloud SQL."
}

variable "tier" {
  type        = string
  default     = "db-perf-optimized-N-2"
  description = "Tipo de máquina para a instância do Cloud SQL."
}

variable "vpc_self_link" {
  type        = string
  description = "Link completo para a VPC onde a instância do Cloud SQL será criada."
}

variable "db_name" {
  type        = string
  description = "Nome do banco de dados a ser criado na instância do Cloud SQL."
}

variable "db_username" {
  type        = string
  description = "Nome de usuário para acessar o banco de dados."
}

variable "db_password" {
  type        = string
  description = "Senha para o usuário do banco de dados."
}

variable "database_version" {
  type        = string
  default     = "POSTGRES_16"
  description = "Versão do banco de dados a ser usado na instância do Cloud SQL."
}

variable "application_name" {
  type        = string
  description = "Nome da aplicação, usado para prefixar recursos."
}

variable "enviroment" {
  type        = string
  description = "Ambiente de desenvolvimento, teste ou produção."
}
