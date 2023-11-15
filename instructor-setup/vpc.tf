variable "region" {
  default     = "eu-west-1"
  description = "AWS region"
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      createdby = "Oliver"
      /* createdon = formatdate("YYYY-MM-DD", timestamp()) */
      course    = "Spark on Kubernetes"
    }
  }
}

data "aws_availability_zones" "available" {}

locals {
  cluster_name = "spark-on-k8s-eks-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name                 = "spark-on-k8s-vpc"
  cidr                 = "192.168.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["192.168.1.0/24", "192.168.2.0/24"]
  public_subnets       = ["192.168.3.0/24", "192.168.4.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}
