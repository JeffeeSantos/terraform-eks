#################################################################################
# VPC Module - Subnets Configuration
#
# Cria subnets públicas e privadas distribuídas em AZs
# Subnets públicas: para recursos com acesso à internet (NAT, LB)
# Subnets privadas: para recursos internos (EKS nodes, DBs)
#################################################################################

# Subnets Públicas
resource "aws_subnet" "public" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.cidr_block, 3, count.index)
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    local.common_tags,
    {
      Name                                   = "${local.name_prefix}-public-subnet-${count.index + 1}"
      "kubernetes.io/role/elb"              = "1"
      "kubernetes.io/role/internal-elb"     = "1"
      "karpenter.sh/discovery"               = local.cluster_name
    }
  )
}

# Subnets Privadas
resource "aws_subnet" "private" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.cidr_block, 3, count.index + 3)
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    local.common_tags,
    {
      Name                                   = "${local.name_prefix}-private-subnet-${count.index + 1}"
      "kubernetes.io/role/internal-elb"     = "1"
      "karpenter.sh/discovery"               = local.cluster_name
    }
  )
}

# Route Table para Subnets Públicas
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-rt-public"
    }
  )
}

# Associação de Route Table para Subnets Públicas
resource "aws_route_table_association" "public" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Route Tables para Subnets Privadas (um por AZ para HA)
resource "aws_route_table" "private" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.enable_nat_gateway ? aws_nat_gateway.main[count.index].id : null
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-rt-private-${count.index + 1}"
    }
  )
}

# Associação de Route Table para Subnets Privadas
resource "aws_route_table_association" "private" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
