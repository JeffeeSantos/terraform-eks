resource "aws_subnet" "eks_subnet_public_1a" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = cidrsubnet(var.cidr_block, 8, 0)
  #availability_zone = "${data.aws_region.current.name}a"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = merge(
    local.tags,
    {
      Name                     = "comunidadedevops-subnet-pub-1a"
      "kubernetes.io/role/elb" = "1"
    }
  )
}

resource "aws_subnet" "eks_subnet_public_1b" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = cidrsubnet(var.cidr_block, 8, 1)
  #availability_zone = "${data.aws_region.current.name}b"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = merge(
    local.tags,
    {
      Name                     = "comunidadedevops-subnet-pub-1b"
      "kubernetes.io/role/elb" = "1"
    }
  )
}