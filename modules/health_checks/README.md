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
| <a name="input_health_check_interval_sec"></a> [health\_check\_interval\_sec](#input\_health\_check\_interval\_sec) | n/a | `number` | `60` | no |
| <a name="input_health_check_name"></a> [health\_check\_name](#input\_health\_check\_name) | n/a | `string` | n/a | yes |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | n/a | `string` | `"/web/database/selector"` | no |
| <a name="input_health_check_port"></a> [health\_check\_port](#input\_health\_check\_port) | n/a | `number` | `8069` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_health_check_self_link"></a> [health\_check\_self\_link](#output\_health\_check\_self\_link) | n/a |
