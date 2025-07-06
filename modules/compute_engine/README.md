## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_null"></a> [null](#provider\_null) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_compute_address.static](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_address) | resource |
| [google_compute_instance_template.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance_template) | resource |
| [google_compute_region_autoscaler.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_autoscaler) | resource |
| [google_compute_region_instance_group_manager.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_region_instance_group_manager) | resource |
| [null_resource.validate_zones](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_password.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [google_compute_image.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_image) | data source |
| [google_compute_zones.available](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_addons_paths"></a> [additional\_addons\_paths](#input\_additional\_addons\_paths) | Caminhos adicionais para addons personalizados. | `list(string)` | `[]` | no |
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Tags adicionais para as instâncias. | `list(string)` | `[]` | no |
| <a name="input_admin_password_override"></a> [admin\_password\_override](#input\_admin\_password\_override) | Senha do administrador da aplicação. Se não for fornecida, será gerada uma senha aleatória. | `string` | `""` | no |
| <a name="input_allow_health_checks"></a> [allow\_health\_checks](#input\_allow\_health\_checks) | Permitir health checks no grupo de instâncias. | `bool` | `true` | no |
| <a name="input_allow_ssh"></a> [allow\_ssh](#input\_allow\_ssh) | Permitir acesso SSH às instâncias. | `bool` | `true` | no |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Nome da aplicação, usado para prefixar recursos. | `string` | n/a | yes |
| <a name="input_attachments_bucket_name"></a> [attachments\_bucket\_name](#input\_attachments\_bucket\_name) | Nome do bucket para attachments | `string` | n/a | yes |
| <a name="input_base_instance_name"></a> [base\_instance\_name](#input\_base\_instance\_name) | Nome base para as instâncias do Compute Engine. | `string` | `"odoo-prod-instance"` | no |
| <a name="input_compute_autoscaler_name"></a> [compute\_autoscaler\_name](#input\_compute\_autoscaler\_name) | Nome do autoscaler para o grupo de instâncias. | `string` | `"odoo-prod-autoscaler"` | no |
| <a name="input_compute_group_manager"></a> [compute\_group\_manager](#input\_compute\_group\_manager) | Nome do gerenciador de grupos de instâncias. | `string` | `"odoo-prod-mig"` | no |
| <a name="input_compute_image_family"></a> [compute\_image\_family](#input\_compute\_image\_family) | Família da imagem do Compute Engine. | `string` | `"debian-12"` | no |
| <a name="input_compute_image_project"></a> [compute\_image\_project](#input\_compute\_image\_project) | Projeto do GCP onde a imagem do Compute Engine está localizada. | `string` | `"debian-cloud"` | no |
| <a name="input_compute_name_prefix"></a> [compute\_name\_prefix](#input\_compute\_name\_prefix) | Prefixo para o nome do template de instância. | `string` | `"odoo-prod-template-"` | no |
| <a name="input_compute_named_port"></a> [compute\_named\_port](#input\_compute\_named\_port) | Porta nomeada para o grupo de instâncias. | `number` | `8069` | no |
| <a name="input_cost_center"></a> [cost\_center](#input\_cost\_center) | n/a | `string` | n/a | yes |
| <a name="input_cpu_target"></a> [cpu\_target](#input\_cpu\_target) | n/a | `number` | n/a | yes |
| <a name="input_db_host"></a> [db\_host](#input\_db\_host) | IP privado do Cloud SQL | `string` | n/a | yes |
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | Database password for Odoo. | `string` | n/a | yes |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | Database username for Odoo. | `string` | n/a | yes |
| <a name="input_disk_size_gb"></a> [disk\_size\_gb](#input\_disk\_size\_gb) | n/a | `number` | n/a | yes |
| <a name="input_disk_type"></a> [disk\_type](#input\_disk\_type) | n/a | `string` | n/a | yes |
| <a name="input_enviroment"></a> [enviroment](#input\_enviroment) | Environment name (e.g., prod, dev, staging). | `string` | n/a | yes |
| <a name="input_initial_size"></a> [initial\_size](#input\_initial\_size) | n/a | `number` | n/a | yes |
| <a name="input_log_level"></a> [log\_level](#input\_log\_level) | Nível de log para a aplicação. | `string` | `"info"` | no |
| <a name="input_machine_type"></a> [machine\_type](#input\_machine\_type) | n/a | `string` | n/a | yes |
| <a name="input_max_cron_threads"></a> [max\_cron\_threads](#input\_max\_cron\_threads) | Número máximo de threads cron para aplicação. | `number` | `2` | no |
| <a name="input_max_size"></a> [max\_size](#input\_max\_size) | n/a | `number` | n/a | yes |
| <a name="input_min_size"></a> [min\_size](#input\_min\_size) | n/a | `number` | n/a | yes |
| <a name="input_odoo_version"></a> [odoo\_version](#input\_odoo\_version) | Versão do Odoo a ser instalada. | `string` | `"16.0"` | no |
| <a name="input_plugins_bucket_name"></a> [plugins\_bucket\_name](#input\_plugins\_bucket\_name) | Nome do bucket para plugins | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | n/a | yes |
| <a name="input_proxy_mode"></a> [proxy\_mode](#input\_proxy\_mode) | Habilitar modo proxy reverso. | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"southamerica-east1"` | no |
| <a name="input_service_account_email"></a> [service\_account\_email](#input\_service\_account\_email) | n/a | `string` | n/a | yes |
| <a name="input_subnet_self_link"></a> [subnet\_self\_link](#input\_subnet\_self\_link) | n/a | `string` | n/a | yes |
| <a name="input_workers"></a> [workers](#input\_workers) | Número de workers para a aplicação. | `number` | `2` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_group_self_link"></a> [instance\_group\_self\_link](#output\_instance\_group\_self\_link) | n/a |
| <a name="output_instance_template_self_link"></a> [instance\_template\_self\_link](#output\_instance\_template\_self\_link) | n/a |
| <a name="output_mig_self_link"></a> [mig\_self\_link](#output\_mig\_self\_link) | n/a |
