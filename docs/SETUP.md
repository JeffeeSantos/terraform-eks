#################################################################################
# PRÓXIMOS PASSOS - Implementação e Configuração
#
# Guia passo a passo para configurar tudo localmente e em produção
#################################################################################

# 📋 Índice

1. [Configuração Local](#configuração-local)
2. [Backend S3 + DynamoDB](#backend-s3--dynamodb)
3. [GitHub Setup](#github-setup)
4. [Primeiro Deploy](#primeiro-deploy)
5. [Validação Final](#validação-final)

---

# 🔧 Configuração Local

## Passo 1: Instalar Ferramentas

### MacOS

\`\`\`bash
# Terraform
brew install terraform

# AWS CLI
brew install awscli

# kubectl
brew install kubectl

# Outros úteis
brew install terraform-docs
brew install tflint
brew install direnv
\`\`\`

### Linux (Ubuntu/Debian)

\`\`\`bash
# Terraform
wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
unzip terraform_1.5.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/

# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Verificar
terraform version
aws --version
kubectl version --client
\`\`\`

## Passo 2: Clone do Repositório

\`\`\`bash
# Clone
git clone https://github.com/seu-usuario/terraform-eks.git
cd terraform-eks

# Verify branches
git branch -a
git fetch origin

# Setup local develop
git checkout develop
git branch --set-upstream-to=origin/develop develop
\`\`\`

## Passo 3: Configure Credenciais AWS

### Opção A: AWS Profile

\`\`\`bash
# Criar profile
aws configure --profile seu-perfil

# Verificar
aws sts get-caller-identity --profile seu-perfil

# Usar no shell
export AWS_PROFILE=seu-perfil
# Ou adicionar em ~/.zshrc/.bashrc
echo 'export AWS_PROFILE=seu-perfil' >> ~/.zshrc
\`\`\`

### Opção B: Variáveis de Ambiente

\`\`\`bash
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_DEFAULT_REGION="us-east-1"

# Verificar
aws sts get-caller-identity
\`\`\`

### Opção C: Assume Role (Recomendado para equipes)

\`\`\`bash
# Assumir role com MFA
aws sts assume-role \\
  --role-arn arn:aws:iam::ACCOUNT:role/TerraformRole \\
  --role-session-name terraform-session \\
  --serial-number arn:aws:iam::ACCOUNT:mfa/seu-usuario \\
  --token-code 123456

# Usar credenciais temporárias retornadas
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_SESSION_TOKEN=...
\`\`\`

---

# 🪣 Backend S3 + DynamoDB

## Passo 1: Criar Bucket S3

\`\`\`bash
# DEV
aws s3api create-bucket \\
  --bucket seu-bucket-terraform-state \\
  --region us-east-1

# PROD (separado!)
aws s3api create-bucket \\
  --bucket seu-bucket-terraform-state-prod \\
  --region us-east-1

# Habilitar versionamento
aws s3api put-bucket-versioning \\
  --bucket seu-bucket-terraform-state \\
  --versioning-configuration Status=Enabled

aws s3api put-bucket-versioning \\
  --bucket seu-bucket-terraform-state-prod \\
  --versioning-configuration Status=Enabled

# Encriptação
aws s3api put-bucket-encryption \\
  --bucket seu-bucket-terraform-state \\
  --server-side-encryption-configuration '{
    \"Rules\": [{
      \"ApplyServerSideEncryptionByDefault\": {
        \"SSEAlgorithm\": \"AES256\"
      }
    }]
  }'

aws s3api put-bucket-encryption \\
  --bucket seu-bucket-terraform-state-prod \\
  --server-side-encryption-configuration '{
    \"Rules\": [{
      \"ApplyServerSideEncryptionByDefault\": {
        \"SSEAlgorithm\": \"AES256\"
      }
    }]
  }'

# Bloquear acesso público
aws s3api put-public-access-block \\
  --bucket seu-bucket-terraform-state \\
  --public-access-block-configuration \\
  'BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true'

aws s3api put-public-access-block \\
  --bucket seu-bucket-terraform-state-prod \\
  --public-access-block-configuration \\
  'BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true'

# Verificar
aws s3 ls seu-bucket-terraform-state/
\`\`\`

## Passo 2: Criar Tabela DynamoDB

\`\`\`bash
# DEV
aws dynamodb create-table \\
  --table-name terraform-state-lock \\
  --attribute-definitions AttributeName=LockID,AttributeType=S \\
  --key-schema AttributeName=LockID,KeyType=HASH \\
  --billing-mode PAY_PER_REQUEST \\
  --region us-east-1

# PROD
aws dynamodb create-table \\
  --table-name terraform-state-lock-prod \\
  --attribute-definitions AttributeName=LockID,AttributeType=S \\
  --key-schema AttributeName=LockID,KeyType=HASH \\
  --billing-mode PAY_PER_REQUEST \\
  --region us-east-1

# Habilitar encriptação
aws dynamodb update-table \\
  --table-name terraform-state-lock \\
  --sse-specification Enabled=true,SSEType=KMS

aws dynamodb update-table \\
  --table-name terraform-state-lock-prod \\
  --sse-specification Enabled=true,SSEType=KMS

# Verificar
aws dynamodb list-tables
\`\`\`

## Passo 3: Atualizar backend.tf

\`\`\`hcl
# envs/dev/backend.tf
terraform {
  backend \"s3\" {
    bucket         = \"seu-bucket-terraform-state\"  # ATUALIZAR
    key            = \"terraform-eks/dev/terraform.tfstate\"
    region         = \"us-east-1\"
    dynamodb_table = \"terraform-state-lock\"          # ATUALIZAR
    encrypt        = true
  }
}

# envs/prod/backend.tf
terraform {
  backend \"s3\" {
    bucket         = \"seu-bucket-terraform-state-prod\"  # ATUALIZAR
    key            = \"terraform-eks/prod/terraform.tfstate\"
    region         = \"us-east-1\"
    dynamodb_table = \"terraform-state-lock-prod\"          # ATUALIZAR
    encrypt        = true
  }
}
\`\`\`

---

# 🐙 GitHub Setup

## Passo 1: Fork do Repositório

\`\`\`bash
# Ir para GitHub e fazer fork
# https://github.com/seu-usuario/terraform-eks/fork

# Clone seu fork
git clone https://github.com/seu-usuario/terraform-eks.git
cd terraform-eks

# Add upstream remote
git remote add upstream https://github.com/seu-usuario/terraform-eks.git
git remote -v
\`\`\`

## Passo 2: Configurar Branch Protection

**GitHub Settings:**

1. **main branch**
   - Settings > Branches > Branch protection rules
   - Pattern: main
   - ✅ Require pull request reviews before merging (2)
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date
   - ✅ Require code reviews from code owners
   - ✅ Dismiss stale pull request approvals
   - ✅ Include administrators

2. **develop branch**
   - Pattern: develop
   - ✅ Require pull request reviews before merging (1)
   - ✅ Require status checks to pass before merging
   - ✅ Require branches to be up to date

## Passo 3: Setup GitHub OIDC (Segurança)

Veja [docs/GITHUB_OIDC.md](../docs/GITHUB_OIDC.md) para setup completo.

\`\`\`bash
# Resumo:
# 1. Criar OIDC provider no IAM
# 2. Criar role com confiança OIDC
# 3. Adicionar secrets no GitHub
#    - AWS_ROLE_ARN
#    - AWS_REGION

# Verificar
aws iam list-open-id-connect-providers
\`\`\`

## Passo 4: Adicionar Secrets

**GitHub > Settings > Secrets and variables > Actions**

Criar:

\`\`\`
AWS_ROLE_ARN = arn:aws:iam::ACCOUNT-ID:role/github-oidc-role
AWS_REGION = us-east-1
SLACK_WEBHOOK_URL = https://hooks.slack.com/services/REPLACE_ME
\`\`\`

## Passo 5: Configurar CODEOWNERS

\`\`\`bash
# .github/CODEOWNERS
modules/ @seu-usuario/devops-team
envs/prod/ @seu-usuario/devops-lead
.github/ @seu-usuario/devops-team
\`\`\`

---

# 🚀 Primeiro Deploy

## Fase 1: Dev (Local)

\`\`\`bash
# Navegar
cd envs/dev

# Customizar variáveis
vim terraform.tfvars
# Atualizar:
# - project_name
# - aws_region
# - availability_zones

# Inicializar
terraform init

# Validar
terraform validate
terraform fmt -recursive ../..

# Planejar
terraform plan -out=tfplan

# Revisar plano (IMPORTANTE!)
terraform show tfplan

# Aplicar
terraform apply tfplan

# Esperar 20-30 minutos...

# Configurar kubectl
aws eks update-kubeconfig --name meu-projeto-dev
kubectl get nodes
\`\`\`

## Fase 2: Dev (GitHub)

\`\`\`bash
# Commit and push
git add envs/dev/
git commit -m \"chore: init dev environment\"
git push origin develop

# Esperar GitHub Actions
# Settings > Actions > terraform.yml

# Verificar status
# GitHub > Actions tab
\`\`\`

## Fase 3: HML (GitHub)

\`\`\`bash
# Customizar HML
cd envs/hml
vim terraform.tfvars
# Atualizar variáveis

git add envs/hml/
git commit -m \"feat: setup hml environment\"
git push origin feature/setup-hml

# Abrir PR > Merge para develop > Auto-deploy
\`\`\`

## Fase 4: Prod (Controlled)

\`\`\`bash
# Customizar Prod
cd envs/prod
vim terraform.tfvars
# Atualizar variáveis (com valores de prod!)

# Criar release branch
git checkout -b release/v1.0.0

# Commit
git add envs/prod/
git commit -m \"feat: setup prod environment\"

# Tag version
git tag -a v1.0.0 -m \"Initial production setup\"

# Push
git push origin release/v1.0.0 --tags

# Abrir PR para main (requer 2+ approvals!)
# Merge > Auto-deploy
\`\`\`

---

# ✅ Validação Final

## Verificações

\`\`\`bash
# 1. Cluster está up
aws eks describe-cluster \\
  --name meu-projeto-dev \\
  --query 'cluster.status'

# 2. Nodes estão healthy
kubectl get nodes
kubectl top nodes

# 3. Pods do sistema estão rodando
kubectl get pods -n kube-system

# 4. VPC Flow Logs ligado
aws logs describe-log-groups \\
  --log-group-name-prefix \"/aws/vpc/flowlogs\"

# 5. Backend S3 com estado
aws s3 ls seu-bucket-terraform-state/

# 6. OIDC configurado
aws iam list-open-id-connect-providers

# 7. GitHub Actions rodando
# GitHub > Actions > terraform.yml > Successful workflows
\`\`\`

## Testes de Funcionalidade

\`\`\`bash
# 1. Deploy uma aplicação de teste
kubectl run nginx --image=nginx --port=80

# 2. Expor via LoadBalancer
kubectl expose pod nginx --type=LoadBalancer

# 3. Testar acesso
kubectl get svc
curl http://EXTERNAL-IP

# 4. Cleanup
kubectl delete pod nginx
kubectl delete svc nginx
\`\`\`

---

# 📝 Próximas Ações

## Curto Prazo (1-2 semanas)

- [ ] Todos os ambientes (dev, hml, prod) criados
- [ ] GitHub Actions pipeline funcionando
- [ ] OIDC configurado
- [ ] Time treinado em GitFlow

## Médio Prazo (1-2 meses)

- [ ] Adicionar monitoring (Prometheus, Grafana)
- [ ] Setup de logging centralizado (ELK/CloudWatch)
- [ ] Configurar autoscaling (CA + HPA)
- [ ] Implementar GitOps (ArgoCD/Flux)

## Longo Prazo (3-6 meses)

- [ ] Multi-region setup
- [ ] Disaster recovery procedures
- [ ] Cost optimization review
- [ ] Security audit (penetration testing)

---

**Status**: Ready to Deploy ✅  
**Última atualização**: 2024-05-13
