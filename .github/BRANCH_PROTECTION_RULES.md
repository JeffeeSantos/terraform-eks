#################################################################################
# Development Branch Protection - Ruleset
# 
# Este arquivo documenta as regras recomendadas para proteção de branches
# Implemente via GitHub UI: Settings > Rules > Rulesets
#################################################################################

# Configurações recomendadas para a branch "main":

# 1. Require a pull request before merging
#    - Require approval from reviewers: 2
#    - Require status checks to pass before merge: YES
#      - terraform fmt (required)
#      - terraform validate (required)
#      - Terraform Plan - dev (required)
#      - Terraform Plan - hml (required)
#      - Terraform Plan - prod (required)
#      - Security Scan (required)

# 2. Require branches to be up to date before merging: YES

# 3. Require conversation resolution before merging: YES

# 4. Require code review from code owners: YES

# 5. Require up-to-date before merge: YES

# 6. Dismiss stale pull request approvals when new commits are pushed: YES

# 7. Restrict who can dismiss pull request reviews: ADMIN_ONLY

# 8. Require signed commits: YES (recomendado para prod)

# 9. Lock branch: NO (Deixar desbloqueado para emergências)

# 10. Include administrators: YES
