#################################################################################
# TROUBLESHOOTING - Problemas Comuns e Soluções
#################################################################################

## 🚨 Problemas com Terraform

### 1. "terraform init" falha com erro de acesso

**Erro:**
```
Error: error reading S3 Bucket in account: AccessDenied
```

**Solução:**

```bash
# Verificar credenciais
aws sts get-caller-identity

# Verificar permissions na bucket
aws s3api get-bucket-versioning --bucket seu-bucket

# Verificar encryption
aws s3api get-bucket-encryption --bucket seu-bucket

# Se estiver usando role OIDC, verificar confiança
aws iam get-role --role-name github-oidc-role

# Força re-download de providers
rm -rf .terraform
rm .terraform.lock.hcl
terraform init -upgrade
```

### 2. "terraform plan" ou "apply" muito lento

**Causa:** EKS leva 15-25 minutos para ser criado

**Solução:**

```bash
# Monitorar via CloudFormation
aws cloudformation list-stacks \
  --stack-status-filter CREATE_IN_PROGRESS UPDATE_IN_PROGRESS

# Ou via CLI
watch 'aws cloudformation describe-stack-resources \
  --stack-name eks-meu-projeto-dev | grep Status'
```

### 3. "Error: error with provider aws"

**Erro:**
```
Error: error with provider configuration: new Client: ...
```

**Solução:**

```bash
# Verificar credenciais
export AWS_PROFILE=seu-profile
aws sts get-caller-identity

# Ou use variáveis
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_DEFAULT_REGION=us-east-1

# Validar provider
terraform -version

# Debug mode
TF_LOG=DEBUG terraform plan
```

### 4. State file corrupted

```bash
# Backup
aws s3 cp s3://seu-bucket/env/dev/terraform.tfstate backup-$(date +%s).tfstate

# Reconstruir
terraform state pull > local.tfstate
# Editar local.tfstate se necessário
terraform state push local.tfstate

# Ou recriado
terraform init -reconfigure
```

---

## 🚨 Problemas com EKS

### 1. Cluster stuck em "CREATING"

**Solução:**

```bash
# Verificar status
aws eks describe-cluster --name meu-projeto-dev --query 'cluster.status'

# Verificar CloudFormation
aws cloudformation describe-stacks --stack-name eks-meu-projeto-dev

# Ver eventos
aws cloudformation describe-stack-events --stack-name eks-meu-projeto-dev

# Se travado (última opção)
aws cloudformation cancel-update-stack --stack-name eks-meu-projeto-dev
# Ou delete
aws cloudformation delete-stack --stack-name eks-meu-projeto-dev
terraform apply -replace module.eks_cluster.aws_eks_cluster.main
```

### 2. Nodes not ready / "NOT_READY"

**Solução:**

```bash
# Verificar status
kubectl get nodes
kubectl describe node NODE_NAME

# Ver logs do nó
kubectl logs -n kube-system -l k8s-app=aws-node
kubectl logs -n kube-system -l k8s-app=kube-proxy

# Ver eventos
kubectl get events -A --sort-by='.lastTimestamp'

# Check Security Groups
aws ec2 describe-security-groups --group-ids sg-xxxxx

# Check EC2 instance
aws ec2 describe-instances --filters Name=tag:eks-cluster,Values=meu-projeto-dev

# Corrigir taints (se necessário)
kubectl taint nodes --all node-role.kubernetes.io/master-
```

### 3. Can't reach Kubernetes API

**Erro:**
```
error: unable to access the URL https://...: dial tcp: i/o timeout
```

**Solução:**

```bash
# Atualizar kubeconfig
aws eks update-kubeconfig --name meu-projeto-dev

# Verificar contexto
kubectl config current-context
kubectl cluster-info

# Testar conectividade
curl -k https://CLUSTER_ENDPOINT/api/v1/namespaces

# Check security group
aws ec2 describe-security-groups \
  --group-ids CLUSTER_SG --query 'SecurityGroups[0].IpPermissions'

# Check endpoint
aws eks describe-cluster --name meu-projeto-dev --query 'cluster.endpoint'
```

### 4. Add-ons failing

**Solução:**

```bash
# Listar add-ons
aws eks list-addons --cluster-name meu-projeto-dev

# Ver detalhes
aws eks describe-addon --cluster-name meu-projeto-dev --addon-name vpc-cni

# Ver health
kubectl get daemonset -n kube-system

# Se falhar, remover e recriar
aws eks delete-addon --cluster-name meu-projeto-dev --addon-name vpc-cni
terraform apply -replace module.eks_cluster.aws_eks_addon.vpc_cni
```

---

## 🚨 Problemas com Networking

### 1. Subnets exhausted

**Erro:** "Not enough IPs in subnet"

**Solução:**

```bash
# Verificar CIDR
aws ec2 describe-subnets --subnet-ids SUBNET_ID

# Calcular IPs disponíveis
aws ec2 describe-subnets --filters Name=vpc-id,Values=VPC_ID

# Se necessário, expandir VPC
# Fazer isso é COMPLEXO - considere recriação

# Ou limitar scope de PODs
kubectl set env daemonset/aws-node -n kube-system \
  WARM_IP_TARGET=5
```

### 2. NAT Gateway not working

**Solução:**

```bash
# Verificar NAT
aws ec2 describe-nat-gateways \
  --filters Name=vpc-id,Values=VPC_ID

# Verificar Elastic IP
aws ec2 describe-addresses

# Se falhar, recríar
terraform destroy -target module.vpc.aws_nat_gateway.main
terraform apply
```

### 3. DNS resolution fails

**Solução:**

```bash
# Testar DNS dentro do cluster
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup kubernetes.default

# Verificar CoreDNS
kubectl logs -n kube-system -l k8s-app=kube-dns

# Reiniciar CoreDNS
kubectl rollout restart -n kube-system deployment/coredns
```

---

## 🚨 Problemas com IAM/IRSA

### 1. Pod can't assume role

**Erro:** "AccessDenied" ao chamar AWS APIs

**Solução:**

```bash
# Verificar service account
kubectl get sa -n kube-system aws-load-balancer-controller -o yaml

# Verificar anotação
kubectl get sa -n kube-system aws-load-balancer-controller \
  -o jsonpath='{.metadata.annotations}'

# Deve conter:
# eks.amazonaws.com/role-arn: arn:aws:iam::ACCOUNT:role/...

# Se não houver, recríar
kubectl annotate serviceaccount \
  -n kube-system aws-load-balancer-controller \
  eks.amazonaws.com/role-arn=arn:aws:iam::ACCOUNT:role/role-name \
  --overwrite

# Deletar pod para forçar remontagem
kubectl delete pod -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
```

### 2. OIDC Provider not working

**Solução:**

```bash
# Verificar OIDC provider
aws iam list-open-id-connect-providers

# Verificar thumbprint
aws iam get-open-id-connect-provider \
  --open-id-connect-provider-arn arn:aws:iam::ACCOUNT:oidc-provider/...

# Validar certificado
echo | openssl s_client -connect token.actions.githubusercontent.com:443 2>&1 | \
  openssl x509 -fingerprint -noout
```

---

## 🚨 Problemas com GitHub Actions

### 1. Workflow fails com "permission denied"

**Causa:** AWS_ROLE_ARN incorreto

**Solução:**

```bash
# Verificar role
aws iam get-role --role-name github-oidc-role

# Verificar trust policy
aws iam get-role --role-name github-oidc-role --query 'Role.AssumeRolePolicyDocument'

# Atualizar GitHub secret
# Settings > Secrets > AWS_ROLE_ARN

# Debug no action
- name: Debug AWS
  run: |
    aws sts get-caller-identity
    echo "Role: $AWS_ROLE_ARN"
```

### 2. Plan comentário não aparece no PR

**Solução:**

```yaml
- name: Comment Plan
  uses: actions/github-script@v6
  with:
    script: |
      const body = 'Terraform Plan:...';
      github.rest.issues.createComment({
        issue_number: context.issue.number,
        owner: context.repo.owner,
        repo: context.repo.repo,
        body: body
      });
```

### 3. Lock file conflict

**Solução:**

```bash
# Remover lock (cuidado!)
rm .terraform.lock.hcl

# Ou atualizar explicitamente
terraform init -upgrade

# Commit
git add .terraform.lock.hcl
git commit -m "chore: update terraform lock"
```

---

## 📊 Debug Mode

### Terraform Debug

```bash
# Verbose logging
TF_LOG=DEBUG terraform plan > debug.log 2>&1
TF_LOG_PATH=/tmp/terraform.log

# JSON output
terraform plan -json | jq .
```

### AWS CLI Debug

```bash
# Verbose
aws eks describe-cluster --name meu-projeto-dev --debug

# Query específica
aws eks describe-cluster --name meu-projeto-dev \
  --query 'cluster.[name,status,endpoint]'
```

### Kubernetes Debug

```bash
# Describe recursos
kubectl describe pod POD_NAME -n NAMESPACE

# Ver logs completos
kubectl logs POD_NAME -n NAMESPACE --all-containers=true --tail=100

# Enter pod
kubectl exec -it POD_NAME -n NAMESPACE -- bash

# Port forward
kubectl port-forward service/my-service 8080:80 -n NAMESPACE
```

---

## 🆘 Escalação

Se nada funcionar:

1. **Coletar informações**

```bash
# Estado Terraform
terraform state show

# Cluster info
aws eks describe-cluster --name meu-projeto-dev
aws ec2 describe-security-groups --group-ids SG_ID
aws cloudformation describe-stack-events --stack-name eks-...

# Logs
kubectl get events -A
kubectl logs -A --all-containers=true --tail=50
```

2. **Abra issue no GitHub** com:
   - Erro completo (sanitizado)
   - Comandos executados
   - Versões (Terraform, AWS CLI, kubectl)
   - Logs (sem dados sensíveis!)

3. **Contate o DevOps Team**

---

**Última atualização**: 2024-05-13
