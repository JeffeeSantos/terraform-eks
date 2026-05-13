#################################################################################
# GITHUB OIDC SETUP - Configurar Autenticação sem Chaves AWS
#
# Este guia explica como usar GitHub OIDC para assumir roles AWS sem
# armazenar chaves de acesso no GitHub (mais seguro!)
#################################################################################

# 📋 Por que usar OIDC?

✅ Sem armazenamento de secrets críticos  
✅ Credenciais temporárias de curta duração  
✅ Rastreamento de quem fez o que no AWS  
✅ Automação mais segura  
✅ Melhor conformidade com compliance  

---

# 🔧 Configuração Passo a Passo

## 1. Criar Identidade OIDC no AWS IAM

```bash
# Ir para IAM > Identity Providers > Create Provider

# Dados:
- Provider Type: OpenID Connect
- Provider URL: https://token.actions.githubusercontent.com
- Audience: sts.amazonaws.com
- Thumbprint: 6938fd4d98bab03faadb97b34396831e3780aea1

# Ou via AWS CLI:
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1 \
  --region us-east-1
```

## 2. Criar Role para GitHub Actions

```bash
# Criar arquivo assume-role-policy.json
cat > assume-role-policy.json << 'EOF'
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::SEU-ACCOUNT-ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:seu-usuario-github/terraform-eks:*"
        }
      }
    }
  ]
}
EOF

# Criar a role
aws iam create-role \
  --role-name github-oidc-role \
  --assume-role-policy-document file://assume-role-policy.json

# Adicionar permissões (estas são LARGAS para desenvolvimento)
# Em produção, restrinja apenas ao necessário!
aws iam attach-role-policy \
  --role-name github-oidc-role \
  --policy-arn arn:aws:iam::aws:policy/AdministratorAccess

echo "role-to-assume: arn:aws:iam::SEU-ACCOUNT-ID:role/github-oidc-role"
```

## 3. Configurar GitHub Secrets

Vá para **Settings > Secrets and variables > Actions**

Crie:

```
AWS_ROLE_ARN = arn:aws:iam::SEU-ACCOUNT-ID:role/github-oidc-role
AWS_REGION = us-east-1
```

## 4. O GitHub Actions Workflow Já Está Configurado!

O arquivo `.github/workflows/terraform.yml` já usa:

```yaml
- uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
    role-session-name: terraform-${{ matrix.environment }}
    aws-region: us-east-1
```

---

# ✅ Verificação

```bash
# Teste a role
aws sts assume-role-with-web-identity \
  --role-arn arn:aws:iam::SEU-ACCOUNT-ID:role/github-oidc-role \
  --role-session-name test \
  --web-identity-token $(curl -s https://token.actions.githubusercontent.com)

# Teste o terraform
cd envs/dev
terraform plan  # Deve funcionar sem chaves!
```

---

# 🔒 Boas Práticas

1. **Restrinja a Role por Repositório**

```json
"StringLike": {
  "token.actions.githubusercontent.com:sub": "repo:seu-usuario-github/terraform-eks:ref:refs/heads/main"
}
```

2. **Use Permissões Mínimas**

Em vez de `AdministratorAccess`, crie policies específicas:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "eks:*",
        "ec2:*",
        "iam:*",
        "s3:*",
        "dynamodb:*"
      ],
      "Resource": "*"
    }
  ]
}
```

3. **Audit Logs**

Monitore chamadas via CloudTrail:

```bash
aws cloudtrail lookup-events \
  --lookup-attributes AttributeKey=ResourceName,AttributeValue=terraform
```

---

# 📝 Documentação Oficial

- [GitHub OIDC Provider](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
- [AWS IAM OIDC](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_create_for-idp_oidc.html)
- [aws-actions/configure-aws-credentials](https://github.com/aws-actions/configure-aws-credentials)
