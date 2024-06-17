provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Terraform = "true"
      Project   = "${var.cluster_name}-project"
    }
  }
}


module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  availability_zones   = var.availability_zones
}

module "eks" {
  // The given value is not suitable for
  //module.eks.var.node_groups declared at modules\eks\variables.tf:11,1-23: list of object required.
  source               = "./modules/eks"
  cluster_name         = var.cluster_name
  subnet_ids           = module.vpc.public_subnets
  node_groups          = var.node_groups
}

module "iam" {
  source = "./modules/iam"
}

module "lb" {
  source   = "./modules/lb"
  subnets  = module.vpc.public_subnets
  vpc_id   = module.vpc.vpc_id
}

module "s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
}
