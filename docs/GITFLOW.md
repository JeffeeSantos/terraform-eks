#################################################################################
# FLUXO GITFLOW - Guia Prático Passo a Passo
#
# Este documento explica como usar GitFlow corretamente no seu repositório
#################################################################################

# 📚 Indice

1. [Conceitos](#conceitos)
2. [Branches](#branches)
3. [Feature Workflow](#feature-workflow)
4. [Release Workflow](#release-workflow)
5. [Hotfix Workflow](#hotfix-workflow)
6. [Boas Práticas](#boas-práticas)

---

## 🎓 Conceitos

GitFlow é um modelo de branching que define quando e como usar branches:

```
┌─ main (produção)
│  ↓
│  ├─ hotfix/* (correções urgentes)
│  │
├─ develop (próxima release)
│  ↓
│  ├─ feature/* (novos recursos)
│  ├─ bugfix/*  (correções)
│  └─ release/* (preparação para prod)
```

### Benefícios

✅ Histórico claro do repositório  
✅ Parallelização segura (múltiplas features)  
✅ Releases controladas e testadas  
✅ Hotfixes rápidos sem quebrar dev  
✅ Rastreabilidade total  

---

## 🌳 Branches

### main

- **Propósito**: Código em PRODUÇÃO
- **Proteção**: Sim (2 reviews, status checks, signed commits)
- **Origem**: Somente de release/* e hotfix/*
- **Deploy**: Automático (apply via pipeline)
- **Ninguém trabalha diretamente aqui!**

### develop

- **Propósito**: Próxima release (homologação)
- **Proteção**: Sim (1 review, status checks)
- **Origem**: feature/*, bugfix/*, release/*
- **Deploy**: Automático para HML
- **Também não trabalhar diretamente!**

### feature/*

- **Padrão**: feature/nome-da-feature
- **Origem**: develop
- **Destino**: develop (via PR)
- **Tempo de vida**: Dias/semanas
- **Exemplos**:
  - feature/adiciona-autoscaling
  - feature/implementa-monitoring
  - feature/upgrade-kubernetes-1.28

### bugfix/*

- **Padrão**: bugfix/corrigir-xy
- **Origem**: develop
- **Destino**: develop (via PR)
- **Tempo de vida**: Dias
- **Exemplos**:
  - bugfix/corrige-vpc-cidr
  - bugfix/arruma-security-group

### release/*

- **Padrão**: release/v1.2.0
- **Origem**: develop (quando está pronto para prod)
- **Destino**: main + develop
- **Tempo de vida**: Dias (enquanto testa)
- **Processo**:
  1. Cria release branch
  2. Testa em produção
  3. Merge para main (com tag)
  4. Back-merge para develop

### hotfix/*

- **Padrão**: hotfix/corrige-bug-critico
- **Origem**: main (emergência!)
- **Destino**: main + develop
- **Tempo de vida**: Horas
- **Exemplos**:
  - hotfix/corrige-cluster-down
  - hotfix/recupera-backup

---

## ✨ Feature Workflow

### Scenario: Adicionar novo tipo de Node

#### 1. Criar feature branch

```bash
# Sempre partir de develop atualizado
git checkout develop
git pull origin develop

# Criar branch feature
git checkout -b feature/adiciona-node-spot

# Ou
git switch -c feature/adiciona-node-spot
```

#### 2. Fazer mudanças

```bash
# Editar arquivos
vim modules/eks-node-group/variables.tf
# Adicionar suporte para capacity_type: SPOT

vim envs/dev/terraform.tfvars
# Adicionar configuração

# Testar localmente
cd envs/dev
terraform init
terraform plan

# Se tudo OK, pode committar
```

#### 3. Commit com boas mensagens

```bash
# Stage changes
git add modules/ envs/

# Commit (seguir Conventional Commits)
git commit -m "feat: adiciona suporte para instâncias SPOT no node group

- Adiciona variável capacity_type ao módulo eks-node-group
- Permite usar SPOT instances para reduzir custo
- Mantém compatibilidade com ON_DEMAND (padrão)

Closes #123"

# Se fez vários commits, organize:
git rebase -i origin/develop  # Squash se necessário
```

#### 4. Push para remote

```bash
git push origin feature/adiciona-node-spot

# Primeira vez?
git push -u origin feature/adiciona-node-spot
```

#### 5. Abrir Pull Request

**No GitHub:**

- Título: "Add SPOT instance support to node groups"
- Base branch: develop
- Description:

```markdown
## Description

Adds support for AWS SPOT instances in EKS node groups to reduce costs.

## Changes

- [x] Added `capacity_type` variable to eks-node-group module
- [x] Updated terraform.tfvars examples
- [x] Tested in dev environment
- [x] No breaking changes

## Related Issues

Closes #123

## Type of change

- [x] Feature
- [ ] Bug fix
- [ ] Breaking change

## Testing

Tested locally:
\`\`\`bash
cd envs/dev
terraform plan  # Plan shows new resource
terraform apply # Applied successfully
kubectl get nodes -L karpenter.sh/capacity-type
\`\`\`

## Screenshots/Logs

\`\`\`
Plan: 0 to add, 1 to change, 0 to destroy
\`\`\`
```

#### 6. Reviewers aprovam

- DevOps team revisa
- Status checks passam
- CI/CD mostra plano
- 1+ approvals necessários

#### 7. Merge para develop

```bash
# No GitHub, clique "Merge pull request"
# Opções:
# - Create a merge commit (preferred para develop/feature)
# - Squash and merge
# - Rebase and merge

# Escolha: "Create a merge commit"
```

#### 8. Atualizar local

```bash
# Voltar para develop
git checkout develop

# Pull última versão
git pull origin develop

# Limpar branch local
git branch -d feature/adiciona-node-spot

# Ou remoto também
git push origin --delete feature/adiciona-node-spot
```

---

## 🚀 Release Workflow

### Scenario: Preparar v1.0.0 para produção

#### 1. Criar release branch (quando develop está estável)

```bash
# Garantir develop está atualizado
git checkout develop
git pull origin develop

# Testar em hml
cd envs/hml
terraform plan  # Sem mudanças? OK!

# Criar release branch
git checkout -b release/v1.0.0
```

#### 2. Bumpar version e preparar

```bash
# Criar arquivo de versão
echo "1.0.0" > VERSION

# Atualizar changelog
cat > CHANGELOG.md << EOF
# Changelog

## [1.0.0] - 2024-05-13

### Added
- VPC com múltiplas AZs
- EKS cluster production-ready
- IAM OIDC provider
- GitHub Actions CI/CD

### Changed
- Refactored modules for reusability

### Fixed
- Security group rules
EOF

# Commit
git add VERSION CHANGELOG.md
git commit -m "chore: prepare release v1.0.0"

# Push
git push -u origin release/v1.0.0
```

#### 3. Testar em produção

```bash
# Simular prod (HML é proxy)
cd envs/hml
terraform plan
terraform apply  # Se necessário

# Ou fazer testes manuais
kubectl get nodes
kubectl get ingress -A
```

#### 4. Abrir PR para main

No GitHub:

- Base: main
- Comparar: release/v1.0.0
- Título: "Release v1.0.0"
- Description:

```markdown
## Release v1.0.0

This release prepares EKS infrastructure for production.

### Checklist

- [x] All tests passed
- [x] HML environment stable
- [x] CHANGELOG updated
- [x] Version bumped
- [x] Documentation updated

### Changes Summary

- Production-grade EKS cluster
- Multi-AZ networking
- IRSA configured
- CI/CD pipeline ready

Requires 2 approvals from DevOps Lead.
```

#### 5. Aprovação e merge para main

```bash
# Depois de 2 approvals, merge para main
# GitHub > Merge pull request > Create a merge commit
```

#### 6. Tag release

```bash
# Volta para main
git checkout main
git pull origin main

# Cria tag
git tag -a v1.0.0 -m "Release v1.0.0 - Production EKS Infrastructure"

# Push tag
git push origin v1.0.0

# GitHub auto-cria Release
# Settings > Releases
```

#### 7. Back-merge para develop

```bash
# Garante develop com todas as mudanças
git checkout develop
git pull origin develop

# Merge release de volta
git merge --no-ff release/v1.0.0 -m "Back-merge release/v1.0.0 to develop"

# Push
git push origin develop

# Delete release branch
git push origin --delete release/v1.0.0
git branch -d release/v1.0.0
```

---

## 🚨 Hotfix Workflow

### Scenario: Cluster EKS offline em produção!

#### 1. Criar hotfix branch URGENTEMENTE

```bash
# Partir de main (não develop!)
git checkout main
git pull origin main

# Hotfix branch
git checkout -b hotfix/corrige-cluster-down
```

#### 2. Corrigir o problema

```bash
# Análise rápida
aws eks describe-cluster --name meu-projeto-prod

# Correção (exemplo: security group muito restritivo)
vim envs/prod/main.tf
# Remover restrição de IP

# Test (em dev primeiro se possível)
cd envs/dev
terraform plan

# Ou testar diretamente se emergência crítica
```

#### 3. Commit urgente

```bash
git add envs/prod/main.tf

git commit -m "fix: corrige security group em produção

ISSUE: EKS API inacessível (cluster offline)
CAUSA: Security group bloqueando HTTPS (443)
SOLUÇÃO: Permite tráfego 0.0.0.0/0 na porta 443

IMPACT: Zero downtime - apenas regra de firewall atualizada
RISK: Baixo - reversível imediatamente

Closes #999 (CRITICAL)"
```

#### 4. Push

```bash
git push -u origin hotfix/corrige-cluster-down
```

#### 5. PR rápida para main

No GitHub:

- Base: main
- Tags: [HOTFIX][PROD][CRITICAL]
- Description clara e concisa

```markdown
## HOTFIX - Cluster Offline

**Priority**: 🚨 CRITICAL

**Issue**: EKS API inaccessible

**Root Cause**: Security group rule too restrictive

**Solution**: Allow HTTPS from anywhere

**Impact**: Zero downtime, API back online

**Rollback**: Revert commit (1 minute)

@devops-lead approval needed (1 person only for hotfix)
```

#### 6. Fast-track approval

DevOps Lead aprova IMEDIATAMENTE (não espera 2 reviews)

#### 7. Merge para main

```bash
# No GitHub, merge immediately
# CI/CD auto-aplica

# Monitorar
aws eks describe-cluster --name meu-projeto-prod --query 'cluster.status'
```

#### 8. Back-merge para develop

```bash
# Importante! Develop precisa da correção também
git checkout develop
git pull origin develop

git merge --no-ff hotfix/corrige-cluster-down -m "Back-merge hotfix to develop"

git push origin develop

# Delete hotfix
git push origin --delete hotfix/corrige-cluster-down
```

#### 9. Post-mortem (depois)

```markdown
# Incident Post-Mortem

## Timeline
- 15:23 - Alerts triggered
- 15:25 - Hotfix identified
- 15:28 - PR merged
- 15:30 - Cluster back online

## Root Cause
Security group accidentally changed during last deployment

## Prevention
- Add security group validation in pipeline
- Add monitoring for API availability
- Update runbook

## Owner
@devops-team
```

---

## ✅ Boas Práticas

### 1. Commit Messages

Seguir Conventional Commits:

```bash
feat:     Nova feature
fix:      Correção de bug
docs:     Documentação
style:    Formatação
refactor: Refatoração
perf:     Performance
test:     Testes
chore:    Ferramentas/build
ci:       CI/CD

Exemplo:
git commit -m "feat: adiciona monitoring

- Configura CloudWatch alarms
- Adiciona dashboard
- Integra com Slack notifications"
```

### 2. PR Review Checklist

Reviewers checam:

- [ ] Terraform code valida (terraform validate passou)
- [ ] Plano não tem surpresas (`terraform plan` revisado)
- [ ] Sem secrets hardcoded
- [ ] Documentação atualizada
- [ ] Mudanças não quebram outros ambientes
- [ ] Testes passam
- [ ] Sem conflitos de merge

### 3. Proteção de Branches

```bash
# main - MÁXIMA proteção
- 2 approvals (incluindo DevOps Lead)
- Status checks obrigatórias
- Requer signed commits
- Dismiss stale reviews
- Require branches up to date

# develop - Proteção média
- 1 approval
- Status checks obrigatórias
- Requer branches up to date

# feature/* - Sem proteção
- Trabalhadores livres para fazer histórico
```

### 4. Limpeza Local

```bash
# Depois de mergear, deletar local
git fetch origin --prune

# Ver branches deletadas remotamente
git branch -vv | grep gone

# Deletar locais órfãos
git branch -vv | grep gone | awk '{print $1}' | xargs git branch -D
```

### 5. Rebase vs Merge

```bash
# Para develop e feature (histórico linear preferido)
git merge --no-ff feature/xyz  # Preserva histórico

# Para releases (clean history)
git merge --ff-only release/v1.0.0
```

---

## 📊 Fluxo Visual Resumido

```
┌── develop ─────────────────────┬─ feature/xyz
│                                │
│  (team trabalha aqui)          │ (seu trabalho)
│                                │
└────────────────────────────────┴─ PR → merge
                 │
                 │ (release stable)
                 │
            release/vX.Y.Z
                 │
            test + approve
                 │
            ├─── main ────────┬─ hotfix/xy
            │                 │
            │ (produção)      │ (emergência)
            │                 │
            └─────────────────┴─ PR → merge rápido
            
            back-merge para develop sempre!
```

---

**Última atualização**: 2024-05-13
