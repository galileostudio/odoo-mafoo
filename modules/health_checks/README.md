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
| [google_compute_health_check.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_health_check) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Nome da aplicação, usado para prefixar recursos. | `string` | n/a | yes |
| <a name="input_health_check_interval_sec"></a> [health\_check\_interval\_sec](#input\_health\_check\_interval\_sec) | Intervalo entre verificações de saúde. | `number` | `60` | no |
| <a name="input_health_check_name"></a> [health\_check\_name](#input\_health\_check\_name) | Nome do health check. | `string` | n/a | yes |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | Caminho do health check. | `string` | `"/web/database/selector"` | no |
| <a name="input_health_check_port"></a> [health\_check\_port](#input\_health\_check\_port) | Porta do health check. | `number` | `8069` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Valor do ID do projeto GCP onde os recursos serão criados. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Valor da região onde os recursos serão criados. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_health_check_self_link"></a> [health\_check\_self\_link](#output\_health\_check\_self\_link) | n/a |
