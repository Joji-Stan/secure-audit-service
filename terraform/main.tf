# 1. LE RÉSEAU (VPC)
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]     # Pour les Workers & BDD
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"] # Pour les Load Balancers

  enable_nat_gateway = true # Permet aux pods privés de sortir sur Internet
  single_nat_gateway = true # Économie de coûts (un seul suffit pour le lab)

  # Tags requis par AWS pour que Kubernetes trouve les sous-réseaux
  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# 2. LE CLUSTER KUBERNETES (EKS)
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.3"

  cluster_name    = var.cluster_name
  cluster_version = "1.27"

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true # Permet d'utiliser kubectl depuis ton Mac

  # Configuration des "Workers" (les serveurs qui lancent les Pods)
  eks_managed_node_groups = {
    general = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"] # Taille standard (2 vCPU, 4GB RAM)
      capacity_type  = "ON_DEMAND"
    }
  }

  # Gestion des droits d'accès
  enable_irsa = true
}