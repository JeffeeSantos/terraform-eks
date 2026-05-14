#################################################################################
# TERRAFORM EKS - ESTRUTURA ENTERPRISE
#
# Documentação completa da arquitetura, setup e fluxo de desenvolvimento
#################################################################################

# 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Arquitetura](#arquitetura)
3. [Pré-requisitos](#pré-requisitos)
4. [Setup Inicial](#setup-inicial)
5. [Fluxo de Desenvolvimento](#fluxo-de-desenvolvimento)
6. [Fluxo de CI/CD](#fluxo-de-cicd)
7. [Guia GitFlow](#guia-gitflow)
8. [Comandos Úteis](#comandos-úteis)
9. [Troubleshooting](#troubleshooting)

---

## 🎯 Visão Geral

Este repositório implementa uma **infraestrutura EKS em escala enterprise** seguindo as melhores práticas de DevOps/SRE com:

✅ **Modular**: Módulos reutilizáveis para VPC, EKS, Node Groups, IAM  
✅ **Multi-ambiente**: Dev, Homologação e Produção com configurações separadas  
✅ **CI/CD Automático**: GitHub Actions com plan e apply  
✅ **IaC Seguro**: Estado remoto em S3 + DynamoDB  
✅ **GitFlow**: Branches protegidas com políticas de revisão  
✅ **Enterprise Ready**: Logging, monitoring, IRSA, VPC Flow Logs  

---

## 🏗️ Arquitetura

### Estrutura de Diretórios

\`\`\`
terraform-eks/
├── .github/
│   ├── workflows/
│   │   └── terraform.yml              # CI/CD pipeline
│   ├── CODEOWNERS                     # Donos de código para PR reviews
│   └── BRANCH_PROTECTION_RULES.md    # Regras de proteção de branches
├── modules/                            # Módulos Terraform reutilizáveis
│   ├── vpc/                           # VPC, subnets, NAT, IGW
│   ├── eks-cluster/                   # Cluster EKS + Add-ons
│   ├── eks-node-group/                # Managed Node Groups
│   ├── iam/                           # Roles para controllers (IRSA)
│   └── load-balancer/                 # ALB/NLB Controller
├── envs/                              # Configurações por ambiente
│   ├── dev/                           # Desenvolvimento
│   │   ├── backend.tf                # Backend S3
│   │   ├── provider.tf               # Providers AWS/K8s/Helm
│   │   ├── versions.tf               # Versões
│   │   ├── variables.tf              # Variáveis
│   │   ├── terraform.tfvars          # Valores
│   │   ├── main.tf                   # Modelos
│   │   └── outputs.tf                # Saídas
│   ├── hml/                           # Homologação
│   └── prod/                          # Produção
├── docs/                              # Documentação adicional
├── README.md                          # Este arquivo
└── .gitignore                         # Git ignore rules
\`\`\`

### Componentes

#### 1. **VPC Module** (modules/vpc/)
- VPC com subnets públicas e privadas
- Internet Gateway (IGW)
- NAT Gateways para alta disponibilidade
- VPC Flow Logs (CloudWatch)
- Route tables otimizadas

#### 2. **EKS Cluster Module** (modules/eks-cluster/)
- Cluster Kubernetes gerenciado
- Control plane com logging (API, Audit, Authenticator)
- OIDC Provider (para IRSA - IAM Roles for Service Accounts)
- Add-ons pré-configurados:
  - VPC CNI
  - CoreDNS
  - kube-proxy
  - EBS CSI Driver
  - EFS CSI Driver

#### 3. **Node Group Module** (modules/eks-node-group/)
- Managed Node Groups (EC2)
- IAM roles automáticas
- Support para SSH (Session Manager)
- Labels e taints customizáveis

#### 4. **IAM Module** (modules/iam/)
- Roles para Cluster Autoscaler
- Roles para Load Balancer Controller
- Roles para External DNS
- Configuração automática de IRSA

#### 5. **Load Balancer Module** (modules/load-balancer/)
- AWS Load Balancer Controller
- Support para ALB e NLB
- IRSA configurada automaticamente

---

## 📋 Pré-requisitos

### Ferramentas Obrigatórias

- **Terraform**: >= 1.5.0
- **AWS CLI**: v2
- **kubectl**: >= 1.27
- **AWS Account**: com permissões de administrador

---

## 🚀 Quick Start

\`\`\`bash
# 1. Clone
git clone <seu-repo>
cd terraform-eks

# 2. Configure AWS
aws configure

# 3. Customize variáveis
cd envs/dev
vim terraform.tfvars

# 4. Inicialize Terraform
terraform init

# 5. Revise o plano
terraform plan

# 6. Aplique
terraform apply

# 7. Configure kubectl
aws eks update-kubeconfig --name meu-projeto-dev
kubectl get nodes
\`\`\`

---

## 🔄 Fluxo GitFlow

### Branches

- **main**: Produção (protegida, apenas PRs)
- **develop**: Homologação (protegida, apenas PRs)
- **feature/***: Features em desenvolvimento
- **bugfix/***: Correções de bugs
- **hotfix/***: Correções urgentes de produção

### Fluxo Básico

\`\`\`bash
# 1. Feature
git checkout develop
git checkout -b feature/sua-feature
# ... fazer mudanças ...
git commit -m \"feat: descrição\"
git push origin feature/sua-feature
# Abrir PR em GitHub → Merge para develop → Deploy automático

# 2. Release (quando develop está estável)
git checkout -b release/v1.0.0
# ... bump version ...
git commit -m \"chore: version 1.0.0\"
# Merge para main → Deploy automático para PROD
# Back-merge para develop

# 3. Hotfix (emergência em prod)
git checkout main
git checkout -b hotfix/corrigir-bug
# ... correção urgente ...
git commit -m \"fix: corrige bug crítico\"
# Merge para main → Deploy automático
# Back-merge para develop
\`\`\`

---

## 🔄 CI/CD Pipeline

### Pull Request

✅ terraform fmt  
✅ terraform validate  
✅ terraform plan  
✅ tflint  
✅ tfsec/trivy  
✅ Comment no PR com plano

### Merge para main/develop

✅ terraform apply (automático)  
✅ Notificação Slack  
✅ Cluster atualizado

### Proteção de Branches

- main: 2 aprovações + status checks
- develop: 1 aprovação + status checks

---

## 📊 Estrutura de Custos

| Componente | Dev | HML | Prod |
|-----------|-----|-----|------|
| NAT Gateways | 1 | 2 | 3 |
| Node Instances | t3.medium (2) | t3.large (3) | m5.large (5) |
| EBS Volume | 100GB | 100GB | 150GB |
| Custo Estimado | ~USD 150/mês | ~USD 400/mês | ~USD 800/mês |

---

## 📚 Documentação Completa

Para guias detalhados, veja:

- [SETUP_COMPLETO.md](docs/SETUP_COMPLETO.md) - Guia passo a passo
- [GITHUB_OIDC.md](docs/GITHUB_OIDC.md) - GitHub OIDC configuration
- [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) - Problemas comuns
- [SECURITY.md](docs/SECURITY.md) - Boas práticas de segurança

---

## 🤝 Support

Dúvidas? Abra uma issue ou consulte a documentação em `docs/`

---

**Status**: ✅ Production Ready  
**Versão**: 1.0.0  
**Última atualização**: 2024-05-13
# 0 test pipeline
