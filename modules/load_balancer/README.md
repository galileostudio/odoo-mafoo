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
| [google_compute_global_forwarding_rule.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule) | resource |
| [google_compute_managed_ssl_certificate.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_managed_ssl_certificate) | resource |
| [google_compute_target_http_proxy.odoo_http_proxy](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_http_proxy) | resource |
| [google_compute_target_https_proxy.this](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_https_proxy) | resource |
| [google_compute_url_map.odoo_url_map](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_url_map) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_backend_service_name"></a> [backend\_service\_name](#input\_backend\_service\_name) | Nome do serviço de backend do load balancer | `string` | n/a | yes |
| <a name="input_cert_name"></a> [cert\_name](#input\_cert\_name) | Nome do certificado SSL gerenciado | `string` | n/a | yes |
| <a name="input_enable_cdn"></a> [enable\_cdn](#input\_enable\_cdn) | Habilita CDN no load balancer | `bool` | `false` | no |
| <a name="input_firewall_name"></a> [firewall\_name](#input\_firewall\_name) | Nome da regra de firewall do load balancer | `string` | n/a | yes |
| <a name="input_health_check_port"></a> [health\_check\_port](#input\_health\_check\_port) | Porta do health check do load balancer | `number` | `8069` | no |
| <a name="input_health_check_self_link"></a> [health\_check\_self\_link](#input\_health\_check\_self\_link) | Self link do health check criado no módulo health\_checks | `string` | n/a | yes |
| <a name="input_http_forwarding_rule_name"></a> [http\_forwarding\_rule\_name](#input\_http\_forwarding\_rule\_name) | Nome da regra de encaminhamento HTTP do load balancer | `string` | n/a | yes |
| <a name="input_https_forwarding_rule_name"></a> [https\_forwarding\_rule\_name](#input\_https\_forwarding\_rule\_name) | Nome da regra de encaminhamento HTTPS do load balancer | `string` | n/a | yes |
| <a name="input_https_proxy_name"></a> [https\_proxy\_name](#input\_https\_proxy\_name) | Nome do proxy HTTPS do load balancer | `string` | n/a | yes |
| <a name="input_instance_group_self_link"></a> [instance\_group\_self\_link](#input\_instance\_group\_self\_link) | Self-link do instance group (não do manager) | `string` | n/a | yes |
| <a name="input_lb_ip_name"></a> [lb\_ip\_name](#input\_lb\_ip\_name) | Nome do endereço IP global do load balancer | `string` | n/a | yes |
| <a name="input_mig_self_link"></a> [mig\_self\_link](#input\_mig\_self\_link) | Self link do Managed Instance Group | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | ID do projeto GCP | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Região GCP onde os recursos serão criados | `string` | n/a | yes |
| <a name="input_ssl_domains"></a> [ssl\_domains](#input\_ssl\_domains) | Lista de domínios para o certificado SSL | `list(string)` | <pre>[<br/>  "exemplo.com"<br/>]</pre> | no |
| <a name="input_url_map_name"></a> [url\_map\_name](#input\_url\_map\_name) | Nome do URL map para o load balancer | `string` | n/a | yes |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | Nome da VPC onde o firewall será aplicado | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lb_ip_address"></a> [lb\_ip\_address](#output\_lb\_ip\_address) | n/a |
