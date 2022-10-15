locals {
    region                  = "ap-northeast-1"
    name                    = "terraform"
    vpc_cidr                = "10.0.0.0/16"
    azs                     = ["ap-northeast-1a", "ap-northeast-1c"]
    public_subnet_cidrs     = ["10.0.0.0/24", "10.0.1.0/24"]
    private_subnet_cidrs    = ["10.0.2.0/24", "10.0.3.0/24"]
    db_name                 = "testdb"
    db_username             = "admin"
}

terraform {
    required_version = "=v1.3.2"        # Terraform Version
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.0"          # AWSプロバイダー
        }
    }
    backend "s3" {
        bucket = "a-s-bucket-kadai"
        key    = "terraform.tfstate"
        region = "ap-northeast-1"
  }
}

provider "aws" {
    region = local.region
}

module "network" {
    source = "./module/network"
    
    name      = local.name
    vpc_cidr  = local.vpc_cidr
    azs       = local.azs
    pub_cidrs = local.public_subnet_cidrs
    pri_cidrs = local.private_subnet_cidrs
}

module "iam" {
    source = "./module/iam"
}

module "ec2" {
    source = "./module/ec2"

    app_name        = local.name
    vpc_id          = module.network.vpc_id
    pub_subnet_ids  = module.network.pub_subnet_ids
}

module "rds" {
    source = "./module/rds"
    
    app_name       = local.name
    vpc_id         = module.network.vpc_id
    pri_subnet_ids = module.network.pri_subnet_ids
}
