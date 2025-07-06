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
| [google_redis_instance.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/redis_instance) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_memory_size_gb"></a> [memory\_size\_gb](#input\_memory\_size\_gb) | n/a | `number` | `1` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | n/a | yes |
| <a name="input_redis_name"></a> [redis\_name](#input\_redis\_name) | n/a | `string` | `"odoo-redis"` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"southamerica-east1"` | no |
| <a name="input_vpc_self_link"></a> [vpc\_self\_link](#input\_vpc\_self\_link) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_host"></a> [host](#output\_host) | n/a |
| <a name="output_port"></a> [port](#output\_port) | n/a |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | n/a |
