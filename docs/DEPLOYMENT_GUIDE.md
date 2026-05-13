#################################################################################
# DEPLOYMENT GUIDE - Como Deployar Mudanças em Produção
#
# Guia passo a passo para fazer deploy de mudanças em produção usando GitFlow
# e GitHub Actions
#################################################################################

# 📋 Índice

1. [Antes de Começar](#antes-de-começar)
2. [Fluxo de Desenvolvimento](#fluxo-de-desenvolvimento)
3. [Review e Merge](#review-e-merge)
4. [Deploy em Produção](#deploy-em-produção)
5. [Validação](#validação)
6. [Rollback](#rollback)
7. [Checklist](#checklist)

---

## ✅ Antes de Começar

### Requisitos

- [ ] Git configurado localmente
- [ ] AWS CLI instalado e configurado
- [ ] Terraform >= 1.5.0
- [ ] kubectl instalado
- [ ] Acesso ao repositório GitHub
- [ ] Acesso à AWS (com credenciais)

### Verificações

```bash
# Verificar versões
git --version
aws --version
terraform version
kubectl version

# Verificar credenciais
aws sts get-caller-identity
aws eks list-clusters --region us-east-1

# Verificar kubeconfig
kubectl cluster-info
```

---

## 🔄 Fluxo de Desenvolvimento

### Fase 1: Desenvolvimento (Você Faz)

#### 1.1 Criar Feature Branch

```bash
# Atualizar develop localmente
git checkout develop
git pull origin develop

# Criar feature branch
git checkout -b feature/sua-mudanca

# Ou bugfix
git checkout -b bugfix/corrige-bug
```

#### 1.2 Fazer Mudanças

```bash
# Editar módulos ou configurações
vim modules/vpc/variables.tf
# ou
vim envs/dev/terraform.tfvars

# Testar localmente em dev
cd envs/dev
terraform init
terraform validate
terraform plan  # Revise o plano!
terraform fmt -recursive ../..
```

#### 1.3 Commit

```bash
# Stage changes
git add modules/ envs/

# Commit com mensagem clara
git commit -m "feat: descrição da mudança

- Detalhes técnicos
- Impacto esperado
- Como testar"

# Se múltiplos commits, reorganizar
git rebase -i origin/develop
```

#### 1.4 Push e PR

```bash
# Push para remote
git push -u origin feature/sua-mudanca

# Abrir PR no GitHub
# - Título descritivo
# - Descrição detalhada
# - Screenshots/logs se aplicável
```

### Fase 2: CI/CD Automático (GitHub Actions)

Quando você abre a PR:

1. ✅ Terraform Format Check
2. ✅ Terraform Validate
3. ✅ TFLint Security Scan
4. ✅ Terraform Plan (todos envs)
5. ✅ Comentário com resultado

**O que você vê:**

```
✅ All checks passed

Environments affected:
- dev (1 to add)
- hml (no changes)

Terraform Plan: 1 resource to add, 0 to change, 0 to destroy

Ready for review!
```

### Fase 3: Code Review (DevOps Team)

Reviewers checam:

- [ ] Código Terraform válido
- [ ] Plano não tem surpresas
- [ ] Sem secrets hardcoded
- [ ] Sem quebra em outros envs
- [ ] Documentação atualizada

**Comentários podem ser adicionados no PR para discutir**

---

## 📝 Review e Merge

### Pré-requisitos para Merge

Sua PR deve ter:

1. ✅ **Aprovação dos Reviewers**
   - develop branch: 1 approval
   - main branch: 2 approvals

2. ✅ **Status Checks Passando**
   - terraform fmt
   - terraform validate
   - terraform plan
   - tflint
   - tfsec/trivy

3. ✅ **Branch Atualizada**
   - Se develop foi atualizado, fazer rebase/merge

4. ✅ **Sem Conflitos**
   - GitHub mostra "No conflicts"

### Solicitando Review

```bash
# No GitHub, atribua reviewers
# Cick "Reviewers" > Select team

# Notifique no Slack
"Hey @devops-team, PR #123 pronta para review!"
```

### Merge para Develop

Quando aprovada e status checks passam:

**GitHub UI:**
1. Click "Merge pull request"
2. Escolha tipo:
   - "Create a merge commit" (preferido)
   - "Squash and merge"
   - "Rebase and merge"
3. Click "Confirm merge"

**Ou via CLI:**

```bash
# Fetch latest
git fetch origin

# Merge localmente
git checkout develop
git merge --no-ff origin/feature/sua-mudanca

# Push
git push origin develop

# Delete branch
git branch -d feature/sua-mudanca
```

### O que Acontece Após Merge em Develop

GitHub Actions:

1. ✅ Detecta push em develop
2. ✅ Terraform Plan (hml environment)
3. ✅ Terraform Apply (hml environment)
4. ✅ Notifica Slack

**Seu cluster HML é automaticamente atualizado!**

---

## 🚀 Deploy em Produção

### Pré-requisitos

- [ ] Mudança testada em dev
- [ ] Aprovada em develop
- [ ] HML com a mudança rodando ok (mínimo 24h)
- [ ] Nenhum incident ativo em produção
- [ ] Janela de manutenção aprovada (se impacto alto)

### Opção 1: Release Branch (RECOMENDADO)

Para mudanças maiores ou releases planejadas:

#### Step 1: Criar Release Branch

```bash
git checkout develop
git pull origin develop

git checkout -b release/v1.2.0
```

#### Step 2: Bump Version

```bash
# Editar VERSION
echo "1.2.0" > VERSION

# Editar CHANGELOG.md
cat >> CHANGELOG.md << EOF

## [1.2.0] - $(date +%Y-%m-%d)

### Added
- Feature X

### Changed
- Updated module Y

### Fixed
- Bug Z
EOF

# Commit
git commit -am "chore: prepare release v1.2.0"
git push -u origin release/v1.2.0
```

#### Step 3: Abrir PR para Main

GitHub:

- Base: main
- Title: "Release v1.2.0"
- Description:

```markdown
## Release v1.2.0

### Changes

- Feature X from #123
- Bugfix Y from #124

### Validation

- [x] HML stable for 24h
- [x] All tests passing
- [x] No critical issues
- [x] Changelog updated

### Rollback Plan

If issues: revert commit (git revert) and trigger re-apply

Requires approval from @devops-lead and @devops-team
```

#### Step 4: Approve e Merge para Main

Após 2 approvals:

```bash
# Merge para main
git checkout main
git merge --no-ff release/v1.2.0

# Tag release
git tag -a v1.2.0 -m "Release v1.2.0"

# Push
git push origin main --tags
```

#### Step 5: GitHub Actions Deploys Automaticamente

1. ✅ Detecta push em main
2. ✅ Terraform Plan (prod)
3. ✅ Terraform Apply (prod) **AUTOMÁTICO**
4. ✅ Notifica Slack
5. ✅ Cluster PROD é atualizado

**Monitorar:**

```bash
# Watch GitHub Actions
# Settings > Actions > terraform.yml

# Ou AWS CLI
watch 'aws cloudformation describe-stacks \
  --stack-name eks-prod \
  --query "Stacks[0].StackStatus"'

# Ou kubectl
watch 'kubectl get nodes'
```

#### Step 6: Back-merge para Develop

```bash
git checkout develop
git merge --no-ff release/v1.2.0 -m "Back-merge v1.2.0 to develop"
git push origin develop

git push origin --delete release/v1.2.0
```

### Opção 2: Hotfix (EMERGÊNCIA)

Para correções críticas em produção:

```bash
# Partir de main
git checkout main
git pull origin main

# Hotfix branch
git checkout -b hotfix/corrige-crítico

# Corrigir
vim envs/prod/main.tf

# Commit
git commit -m "fix: corrige issue crítico em prod

ISSUE: cluster offline
CAUSA: security group
SOLUÇÃO: allow traffic 443
IMPACT: zero downtime"

# Push
git push -u origin hotfix/corrige-crítico

# PR para main (FAST-TRACK)
# Merge imediatamente após DevOps Lead approval

# Back-merge para develop
git checkout develop
git merge --no-ff hotfix/corrige-crítico
git push origin develop
```

---

## ✅ Validação

### Pós-Deploy Checklist

Depois do apply, verificar:

#### 1. Cluster Health

```bash
# Configurar kubeconfig
aws eks update-kubeconfig --name meu-projeto-prod

# Check nodes
kubectl get nodes
kubectl top nodes

# Check system pods
kubectl get pods -n kube-system

# Check ingress/services
kubectl get ingress -A
kubectl get svc -A
```

#### 2. AWS Resources

```bash
# EKS cluster
aws eks describe-cluster --name meu-projeto-prod --query 'cluster.status'

# EC2 instances
aws ec2 describe-instances \
  --filters Name=tag:eks-cluster,Values=meu-projeto-prod \
  --query 'Reservations[*].Instances[*].[InstanceId,State.Name,InstanceType]'

# VPC
aws ec2 describe-vpcs \
  --filters Name=tag:Environment,Values=prod \
  --query 'Vpcs[0].[VpcId,CidrBlock]'
```

#### 3. Logs e Monitoring

```bash
# EKS Control Plane Logs
aws logs tail /aws/eks/meu-projeto-prod/cluster --follow

# Node logs
kubectl logs -n kube-system -l component=kubelet

# Check events
kubectl get events -A --sort-by='.lastTimestamp'
```

#### 4. Application Tests

```bash
# Se tem aplicações rodando
kubectl get deployment -A
kubectl rollout status deployment/app-name -n namespace

# Health checks
kubectl get svc -n namespace
curl http://service-endpoint/health
```

#### 5. Notificar Team

```bash
# Slack notification
"🚀 v1.2.0 deployed to production

✅ Cluster healthy
✅ All pods running
✅ No errors in logs

Status: READY"
```

---

## 🔄 Rollback

Se algo der errado, fazer rollback:

### Opção 1: Revert Commit

```bash
# Identifique o commit
git log --oneline main | head -5

# Revert
git revert COMMIT_HASH

# GitHub Actions auto-aplica
# Cluster volta ao estado anterior
```

### Opção 2: Manual Rollback

```bash
# Voltar em produção para versão anterior
cd envs/prod

# Editar terraform.tfvars ou variables se necessário
vim terraform.tfvars

# Plan (deve mostrar o que vai reverter)
terraform plan

# Apply reversal
terraform apply

# Verificar
kubectl get nodes
```

### Opção 3: Restaurar do Backup

```bash
# Se state file foi corrompido
aws s3 cp s3://seu-bucket/backup-2024-05-13.tfstate .

terraform state push backup-2024-05-13.tfstate

# Aplicar estado
terraform apply
```

---

## 📋 Checklist de Deployment

### Antes de Abrir PR

- [ ] Código testado localmente (terraform plan)
- [ ] Sem secrets hardcoded
- [ ] Commit messages claras
- [ ] Documentação atualizada
- [ ] Sem conflitos com develop

### Antes de Mergear para Develop

- [ ] Mínimo 1 approval
- [ ] Status checks passando
- [ ] Plano revisado e validado
- [ ] Branch atualizada com develop

### Antes de Release para Prod

- [ ] HML estável por 24h+
- [ ] Zero critical issues em HML
- [ ] Release branch criada e testada
- [ ] Changelog atualizado
- [ ] Version bumped

### Antes de Mergear para Main

- [ ] 2+ approvals (incluindo DevOps Lead)
- [ ] Plano revisado 2x
- [ ] Rollback plan documentado
- [ ] Team notificado
- [ ] Janela de manutenção confirmada

### Pós-Deploy

- [ ] Cluster health validada
- [ ] Logs sem erros
- [ ] Aplicações rodando normalmente
- [ ] Team notificado do sucesso
- [ ] Metrics monitoradas

---

## 🆘 Troubleshooting Deployment

### Deploy falhou - Cluster degraded

1. **Verificar erro**
   ```bash
   aws cloudformation describe-stack-events --stack-name eks-prod
   kubectl get events -A
   ```

2. **Fazer rollback**
   ```bash
   git revert COMMIT_HASH
   # GitHub Actions auto-aplica
   ```

3. **Investigar causa**
   - Verificar plano que foi aceito
   - Revisar mudanças
   - Testar novamente em dev

### Pods não estão up

```bash
# Debug
kubectl describe pod POD_NAME -n namespace
kubectl logs POD_NAME -n namespace

# Verificar recursos
kubectl top nodes
kubectl get pvc

# Check networking
kubectl get network-policy
```

### Conexão com AWS APIs falha

```bash
# Check IAM
aws iam list-roles | grep eks

# Check OIDC
aws iam list-open-id-connect-providers

# Check service account
kubectl describe sa -n kube-system aws-load-balancer-controller
```

---

**Status**: Production Ready ✅  
**Última atualização**: 2024-05-13
