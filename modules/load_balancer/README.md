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
| [google_compute_backend_service.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_service) | resource |
| [google_compute_firewall.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_firewall) | resource |
| [google_compute_global_address.lb_ip](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource |
| [google_compute_global_forwarding_rule.http](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule) | resource |
| [google_compute_global_forwarding_rule.https](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule) | resource |
| [google_compute_managed_ssl_certificate.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_managed_ssl_certificate) | resource |
| [google_compute_target_http_proxy.http_proxy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_http_proxy) | resource |
| [google_compute_target_https_proxy.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_https_proxy) | resource |
| [google_compute_url_map.url_map](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_url_map) | resource |
| [google_compute_ssl_certificate.existing](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/compute_ssl_certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Nome da aplicação, usado para prefixar recursos. | `string` | n/a | yes |
| <a name="input_enable_cdn"></a> [enable\_cdn](#input\_enable\_cdn) | Habilita CDN no load balancer | `bool` | `false` | no |
| <a name="input_existing_ssl_certificate_name"></a> [existing\_ssl\_certificate\_name](#input\_existing\_ssl\_certificate\_name) | Nome de um certificado SSL já existente no GCP. Se fornecido, este certificado será usado ao invés de criar um novo | `string` | `null` | no |
| <a name="input_health_check_port"></a> [health\_check\_port](#input\_health\_check\_port) | Porta do health check do load balancer | `number` | `8069` | no |
| <a name="input_health_check_self_link"></a> [health\_check\_self\_link](#input\_health\_check\_self\_link) | Self link do health check criado no módulo health\_checks | `string` | n/a | yes |
| <a name="input_instance_group_self_link"></a> [instance\_group\_self\_link](#input\_instance\_group\_self\_link) | Self-link do instance group (não do manager) | `string` | n/a | yes |
| <a name="input_mig_self_link"></a> [mig\_self\_link](#input\_mig\_self\_link) | Self link do Managed Instance Group | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | ID do projeto GCP | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Região GCP onde os recursos serão criados | `string` | n/a | yes |
| <a name="input_ssl_domains"></a> [ssl\_domains](#input\_ssl\_domains) | Lista de domínios para o certificado SSL (usado apenas se existing\_ssl\_certificate\_name não for fornecido) | `list(string)` | `[]` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Nome da VPC onde o firewall será aplicado | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lb_ip_address"></a> [lb\_ip\_address](#output\_lb\_ip\_address) | n/a |
