# Executando todos os módulos com Terragrunt

## Estrutura dos módulos

Este diretório contém os seguintes módulos do Terraform:

- `vpc/` - Configuração da VPC
- `cloud_sql/` - Configuração do Cloud SQL
- `compute_engine/` - Configuração das instâncias do Compute Engine
- `cloud_storage_plugins/` - Configuração do Cloud Storage para plugins
- `cloud_storage_attachments/` - Configuração do Cloud Storage para attachments
- `health_checks/` - Configuração dos health checks
- `load_balancer/` - Configuração do load balancer

## Como executar todos os módulos

### 1. Executar todos os módulos de uma vez:

```bash
# Navegar para o diretório
cd paycon_odoo_cloud

# Executar todos os módulos (comando principal)
terragrunt run-all apply

# Executar com aprovação automática
terragrunt run-all apply --terragrunt-non-interactive
```

### 2. Executar apenas o plano de todos os módulos:

```bash
terragrunt run-all plan
```

### 3. Executar com aprovação automática:

```bash
terragrunt run-all apply --terragrunt-non-interactive
```

### 4. Executar em paralelo (mais rápido):

```bash
terragrunt run-all apply --terragrunt-parallelism 4
```

### 5. Destruir todos os recursos:

```bash
terragrunt run-all destroy
```

## Ordem de execução

O Terragrunt executará os módulos na seguinte ordem baseada nas dependências:

1. VPC
2. Cloud SQL
3. Compute Engine
4. Cloud Storage (plugins e attachments)
5. Health Checks
6. Load Balancer

## Variáveis comuns configuradas

- `project_name`: "paycon-odoo-cloud"
- `environment`: "production"

Estas variáveis podem ser alteradas no arquivo `terragrunt.hcl` se necessário. 
