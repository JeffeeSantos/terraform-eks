resource "aws_subnet" "eks_subnet_private_1a" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = cidrsubnet(var.cidr_block, 8, 2)
  #availability_zone = "${data.aws_region.current.name}a"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = merge(
    local.tags,
    {
      Name                              = "comunidadedevops-subnet-priv-1a"
      "kubernetes.io/role/internal-elb" = "1"
    }
  )
}

resource "aws_subnet" "eks_subnet_private_1b" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = cidrsubnet(var.cidr_block, 8, 3)
  #availability_zone = "${data.aws_region.current.name}b"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false

  tags = merge(
    local.tags,
    {
      Name                              = "comunidadedevops-subnet-priv-1b"
      "kubernetes.io/role/internal-elb" = "1"
    }
  )
}