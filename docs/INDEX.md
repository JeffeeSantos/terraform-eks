#################################################################################
# DOCUMENTAÇÃO - Índice Completo
#
# Guia de navegação para toda a documentação do projeto
#################################################################################

# 📚 Documentação do Terraform EKS Enterprise

## Início Rápido

1. **[README.md](../README.md)** ⭐ **COMECE AQUI**
   - Visão geral do projeto
   - Arquitetura dos módulos
   - Pré-requisitos
   - Quick start (5 minutos)
   - Comandos úteis

## 🚀 Guias de Implementação

### Para Desenvolvedores

1. **[GITFLOW.md](GITFLOW.md)** - Como usar GitFlow corretamente
   - Branches e seus propósitos
   - Feature workflow completo
   - Release workflow
   - Hotfix para emergências
   - Boas práticas de commits

2. **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** - Como fazer deploy
   - Fluxo de desenvolvimento passo a passo
   - Código review e merge
   - Deploy em produção
   - Validação pós-deploy
   - Como fazer rollback

3. **[GITHUB_OIDC.md](GITHUB_OIDC.md)** - Setup de segurança
   - Configure OIDC sem chaves AWS
   - IAM roles para GitHub Actions
   - Boas práticas de segurança
   - Verificações e testes

### Para DevOps/SRE

1. **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)** - Resolver problemas
   - Problemas com Terraform
   - Problemas com EKS
   - Problemas com networking
   - Problemas com IAM/IRSA
   - Problemas com GitHub Actions
   - Debug mode e escalação

2. **[MODULES.md](MODULES.md)** - Documentação dos módulos
   - VPC Module
   - EKS Cluster Module
   - Node Group Module
   - IAM Module
   - Load Balancer Module

3. **[SECURITY.md](SECURITY.md)** - Boas práticas de segurança
   - Network security
   - IAM security
   - Secrets management
   - Compliance checks

### Para DevOps Lead / Arquitetos

1. **[ARCHITECTURE.md](ARCHITECTURE.md)** - Design da solução
   - Decisões arquiteturais
   - Trade-offs
   - Escalabilidade
   - High availability
   - Disaster recovery

2. **[COST_OPTIMIZATION.md](COST_OPTIMIZATION.md)** - Otimizar custos
   - Estimativas por ambiente
   - Reduzir custos
   - Spot instances
   - Reserved instances
   - Monitoramento de custos

## 📋 Estrutura de Diretórios

```
.
├── README.md                          ⭐ Comece aqui
├── .github/
│   ├── workflows/
│   │   └── terraform.yml             # CI/CD pipeline
│   ├── CODEOWNERS                    # Donos de código
│   └── BRANCH_PROTECTION_RULES.md   # Proteção de branches
├── modules/                          # Código reutilizável
│   ├── vpc/                         # Rede (VPC, Subnets, NAT, IGW)
│   ├── eks-cluster/                 # Cluster EKS + Add-ons
│   ├── eks-node-group/              # Worker Nodes
│   ├── iam/                         # IAM Roles e Policies
│   └── load-balancer/               # ALB/NLB Controller
├── envs/                            # Ambientes (Dev, HML, Prod)
│   ├── dev/                         # Desenvolvimento
│   ├── hml/                         # Homologação
│   └── prod/                        # Produção
├── docs/                            # Documentação
│   ├── INDEX.md                    # Este arquivo
│   ├── GITFLOW.md                  # GitFlow guia
│   ├── DEPLOYMENT_GUIDE.md         # Como fazer deploy
│   ├── GITHUB_OIDC.md              # OIDC setup
│   ├── TROUBLESHOOTING.md          # Troubleshooting
│   ├── MODULES.md                  # Documentação de módulos
│   ├── SECURITY.md                 # Boas práticas de segurança
│   ├── ARCHITECTURE.md             # Design da solução
│   └── COST_OPTIMIZATION.md        # Otimização de custos
└── .gitignore                       # Ignore rules
```

## 🎯 Por Caso de Uso

### "Quero começar agora"
→ [README.md](../README.md) + [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)

### "Não sei como usar Git"
→ [GITFLOW.md](GITFLOW.md)

### "Quero fazer uma feature"
→ [GITFLOW.md](GITFLOW.md) > Feature Workflow

### "Quero fazer deploy em produção"
→ [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)

### "Algo está quebrado!"
→ [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

### "Como funciona a segurança?"
→ [GITHUB_OIDC.md](GITHUB_OIDC.md) + [SECURITY.md](SECURITY.md)

### "Como reduzir custos?"
→ [COST_OPTIMIZATION.md](COST_OPTIMIZATION.md)

### "Qual é a arquitetura?"
→ [ARCHITECTURE.md](ARCHITECTURE.md)

## 🔑 Arquivos Principais

### No Root

| Arquivo | Descrição |
|---------|-----------|
| README.md | Documentação principal |
| .gitignore | Arquivos a não fazer commit |
| LICENSE | Licença do projeto |

### Em modules/

| Módulo | Descrição |
|--------|-----------|
| vpc/ | VPC, subnets, NAT, IGW, Flow Logs |
| eks-cluster/ | Cluster EKS, Control Plane, OIDC |
| eks-node-group/ | EC2 Managed Nodes |
| iam/ | Roles para Controllers |
| load-balancer/ | ALB/NLB IAM Role |

### Em envs/

Cada ambiente (dev, hml, prod) tem:

| Arquivo | Descrição |
|---------|-----------|
| versions.tf | Versões do Terraform e providers |
| backend.tf | Configuração de estado remoto (S3) |
| provider.tf | Configuração dos providers |
| variables.tf | Definição de variáveis |
| terraform.tfvars | Valores das variáveis |
| main.tf | Chamada dos módulos |
| outputs.tf | Saídas dos outputs |

## 💡 Conceitos Importantes

### GitFlow Branches

```
main        → Produção (protegida, deploy automático)
develop     → Próxima release (protegida)
feature/*   → Desenvolvimento de features
bugfix/*    → Correção de bugs
release/*   → Preparação para produção
hotfix/*    → Correções urgentes de prod
```

### Ambientes

```
dev         → Desenvolvimento rápido, custos baixos
hml         → Homologação, similar a prod
prod        → Produção, maxima HA e performance
```

### CI/CD Flow

```
PR aberta         → terraform fmt + validate + plan
↓
Aprovado          → Merge para develop/main
↓
GitHub Actions    → terraform apply automático
↓
Cluster Updated   → Notificação Slack
```

## 📞 Suporte

### Perguntas Frequentes

1. **Como adiciono uma nova instância de Node Group?**
   - Edite `envs/ENV/terraform.tfvars` > `node_group_desired_size`
   - Abra PR, revise plano, merge

2. **Como mudo a versão do Kubernetes?**
   - Edite `envs/ENV/terraform.tfvars` > `cluster_version`
   - Teste em dev/hml primeiro
   - Deploy em prod

3. **Como faço backup do estado?**
   - Estado está em S3 com versionamento
   - Restauração: `aws s3 cp s3://bucket/backup.tfstate .`

4. **Como monitoro custos?**
   - Ver [COST_OPTIMIZATION.md](COST_OPTIMIZATION.md)
   - Use AWS Cost Explorer
   - Monitore NAT Gateway usage

5. **Como adiciono novos providers (Prometheus, ArgoCD)?**
   - Use Helm charts via `helm_release` (adicione novo módulo)
   - Ou implemente no cluster manualmente

### Contato

- 📧 Email: devops-team@empresa.com
- 💬 Slack: #devops-engineering
- 📋 GitHub Issues: github.com/seu-usuario/terraform-eks/issues

## 🔍 Checklist de Setup

- [ ] Clonar repositório
- [ ] Instalar ferramentas (Terraform, AWS CLI, kubectl)
- [ ] Configurar credenciais AWS
- [ ] Criar S3 bucket para backend
- [ ] Criar tabela DynamoDB para lock
- [ ] Customizar terraform.tfvars (dev)
- [ ] Executar terraform init
- [ ] Executar terraform plan
- [ ] Executar terraform apply
- [ ] Configurar kubeconfig
- [ ] Verificar nodes e pods

## 📊 Estrutura de Ambientes

### Development

- **Custo**: ~USD 150/mês
- **VPC**: 10.0.0.0/16
- **Nodes**: t3.medium (2)
- **NAT**: 1 gateway
- **Logs**: 7 dias
- **Uso**: Testes rápidos, experimentação

### Homologação

- **Custo**: ~USD 400/mês
- **VPC**: 172.16.0.0/16
- **Nodes**: t3.large (3)
- **NAT**: 2 gateways
- **Logs**: 30 dias
- **Uso**: Testes antes de prod, simula prod

### Produção

- **Custo**: ~USD 800+/mês
- **VPC**: 192.168.0.0/16
- **Nodes**: m5.large (5-10)
- **NAT**: 3 gateways (HA)
- **Logs**: 90 dias
- **Uso**: Workloads críticos

## 🎓 Aprender Mais

### Terraform

- [Terraform Docs](https://www.terraform.io/docs)
- [AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

### Kubernetes

- [Kubernetes Docs](https://kubernetes.io/docs)
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)

### AWS

- [EKS Documentation](https://docs.aws.amazon.com/eks)
- [VPC Best Practices](https://docs.aws.amazon.com/vpc/latest/userguide)
- [IAM Security Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)

### DevOps

- [GitFlow Model](https://nvie.com/posts/a-successful-git-branching-model/)
- [Conventional Commits](https://www.conventionalcommits.org)

---

**Versão**: 1.0.0  
**Status**: Production Ready ✅  
**Última atualização**: 2024-05-13  
**Mantido por**: DevOps Team
