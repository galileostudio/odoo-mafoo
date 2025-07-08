
## Início Rápido

### Pré-requisitos

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/) >= 0.45
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install)
- Conta GCP com as APIs necessárias habilitadas

### Configuração Inicial

1. **Configure as credenciais do GCP:**
```bash
gcloud auth login
gcloud auth application-default login
```

2. **Configure as variáveis do projeto:**
```bash
# Copie o arquivo de exemplo
cp secret.hcl-example secrets.hcl

# Edite com suas configurações
vim secrets.hcl
```

3. **Execute a infraestrutura:**
```bash
cd paycon_odoo_cloud

# Para todos os módulos
terragrunt run-all apply

# Para módulos específicos
terragrunt run-all apply \
  --terragrunt-include-dir vpc \
  --terragrunt-include-dir compute_engine \
  --terragrunt-include-dir cloud_sql
```

## 🔧 Configuração

### Variáveis Principais

| Variável | Descrição | Padrão | Obrigatória |
|----------|-----------|---------|-------------|
| `project_id` | ID do projeto GCP | - | ✅ |
| `region` | Região GCP | `southamerica-east1` | ✅ |
| `machine_type` | Tipo de máquina | `e2-standard-2` | ✅ |
| `ssl_domains` | Domínios SSL | - | ✅ |
| `db_username` | Usuário do banco | `odoo` | ✅ |
| `db_password` | Senha do banco | - | ✅ |

### Configuração do Odoo

O projeto instala automaticamente o Odoo 17 Community Edition com:

- Conexão automática ao Cloud SQL
- Integração com Cloud Storage
- Configuração de SSL/TLS
- Monitoramento e logs integrados

## 🛠️ Comandos Úteis

```bash
# Planejar mudanças
terragrunt run-all plan

# Aplicar mudanças
terragrunt run-all apply

# Destruir recursos
terragrunt run-all destroy

# Aplicar com aprovação automática
terragrunt run-all apply --terragrunt-non-interactive

# Aplicar em paralelo
terragrunt run-all apply --terragrunt-parallelism 4

# Aplicar módulos específicos
terragrunt run-all apply \
  --terragrunt-include-dir vpc \
  --terragrunt-include-dir cloud_sql
```

## Recursos Criados

- **VPC**: Rede privada com firewall personalizado
- **Cloud SQL**: PostgreSQL com backup automático
- **Compute Engine**: Instâncias gerenciadas com auto-scaling
- **Load Balancer**: HTTPS com certificado SSL gerenciado
- **Cloud Storage**: Buckets para plugins e attachments
- **Health Checks**: Monitoramento de saúde das instâncias
- **Memorystore**: Redis para cache de sessões

## Segurança

- Instâncias em rede privada
- Banco de dados sem IP público
- SSL/TLS obrigatório
- Firewall restritivo
- Service accounts com permissões mínimas

## Tags e Organização

Todos os recursos são criados com tags padronizadas:
- `application`: odoo
- `environment`: production
- `managed-by`: terraform

## Monitoramento

O projeto inclui:
- Health checks automáticos
- Logs centralizados no Cloud Logging
- Métricas no Cloud Monitoring
- Alertas configuráveis

---

**Versão do Odoo:** 17.0 Community Edition
