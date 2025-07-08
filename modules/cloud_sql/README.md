## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_sql_database.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database) | resource |
| [google_sql_database_instance.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_database_instance) | resource |
| [google_sql_user.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/sql_user) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Nome da aplicação, usado para prefixar recursos. | `string` | n/a | yes |
| <a name="input_database_version"></a> [database\_version](#input\_database\_version) | Versão do banco de dados a ser usado na instância do Cloud SQL. | `string` | `"POSTGRES_14"` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Nome do banco de dados a ser criado na instância do Cloud SQL. | `string` | n/a | yes |
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | Senha para o usuário do banco de dados. | `string` | n/a | yes |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | Nome de usuário para acessar o banco de dados. | `string` | n/a | yes |
| <a name="input_enviroment"></a> [enviroment](#input\_enviroment) | Ambiente de desenvolvimento, teste ou produção. | `string` | n/a | yes |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | Nome da instância do Cloud SQL. | `string` | `"database"` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Valor do ID do projeto GCP onde os recursos serão criados. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Valor da região onde os recursos serão criados. | `string` | n/a | yes |
| <a name="input_tier"></a> [tier](#input\_tier) | Tipo de máquina para a instância do Cloud SQL. | `string` | `"db-f1-micro"` | no |
| <a name="input_vpc_self_link"></a> [vpc\_self\_link](#input\_vpc\_self\_link) | Link completo para a VPC onde a instância do Cloud SQL será criada. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_name"></a> [db\_name](#output\_db\_name) | n/a |
| <a name="output_db_password"></a> [db\_password](#output\_db\_password) | n/a |
| <a name="output_db_username"></a> [db\_username](#output\_db\_username) | n/a |
| <a name="output_instance_connection_name"></a> [instance\_connection\_name](#output\_instance\_connection\_name) | n/a |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | n/a |
