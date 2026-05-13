#################################################################################
# VPC Module - README
#
# Documentação do módulo VPC explicando uso, exemplos e requisitos
#################################################################################

# Módulo VPC - Rede Virtual da AWS

## Descrição

Este módulo cria uma VPC altamente disponível com subnets públicas e privadas
distribuídas entre múltiplas zonas de disponibilidade.

## Características

- ✅ VPC com CIDR block customizável
- ✅ Subnets públicas e privadas em múltiplas AZs
- ✅ Internet Gateway para acesso à internet
- ✅ NAT Gateways para alta disponibilidade
- ✅ VPC Flow Logs para monitoramento
- ✅ Tags automáticas para Kubernetes e Karpenter
- ✅ Route tables otimizadas

## Uso

### Exemplo básico

\`\`\`hcl
module "vpc" {
  source = "../../modules/vpc"

  environment         = var.environment
  project_name        = var.project_name
  cidr_block          = var.cidr_block
  availability_zones  = var.availability_zones
  enable_nat_gateway  = true
  enable_flow_logs    = true

  tags = local.common_tags
}
\`\`\`

## Variáveis Requeridas

| Nome | Tipo | Descrição |
|------|------|-----------|
| environment | string | dev, hml ou prod |
| project_name | string | Nome do projeto |
| cidr_block | string | CIDR block da VPC |
| availability_zones | list(string) | Zonas de disponibilidade (2-4) |

## Variáveis Opcionais

| Nome | Tipo | Padrão | Descrição |
|------|------|--------|-----------|
| enable_nat_gateway | bool | true | Habilitar NAT Gateway |
| enable_vpn_gateway | bool | false | Habilitar VPN Gateway |
| enable_flow_logs | bool | true | Habilitar VPC Flow Logs |
| flow_logs_retention_in_days | number | 7 | Retenção dos flow logs |
| tags | map(string) | {} | Tags adicionais |

## Outputs

| Nome | Descrição |
|------|-----------|
| vpc_id | ID da VPC |
| vpc_cidr | CIDR block da VPC |
| internet_gateway_id | ID do IGW |
| public_subnets | IDs das subnets públicas |
| private_subnets | IDs das subnets privadas |
| nat_gateway_ips | IPs públicos dos NAT Gateways |
| availability_zones | Zonas de disponibilidade utilizadas |

## Notas de Design

### Distribuição de CIDR

- Subnets Públicas: índices 0, 1, 2
- Subnets Privadas: índices 3, 4, 5

### Tags Kubernetes

As seguintes tags são adicionadas automaticamente:
- \`kubernetes.io/role/elb\`: Subnets públicas
- \`kubernetes.io/role/internal-elb\`: Subnets pública e privada
- \`karpenter.sh/discovery\`: Identificação para Karpenter

## Custo Estimado

- NAT Gateway: USD 0.035/hora por gateway + dados processados
- Elastic IP: USD 0.005/hora por IP (quando não associado)
- VPC Flow Logs: USD 0.50/hora por mês de traffic volume + armazenamento CloudWatch

## Próximos Passos

Após criar a VPC, você pode:
1. Criar o cluster EKS com o módulo eks-cluster
2. Adicionar node groups com o módulo eks-node-group
3. Configurar o load balancer com o módulo load-balancer
