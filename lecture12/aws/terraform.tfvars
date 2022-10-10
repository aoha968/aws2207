#--------------------------------------------------------------
# General
#--------------------------------------------------------------

name   = "terraform"
region = "ap-northeast-1"

#--------------------------------------------------------------
# Network
#--------------------------------------------------------------

vpc_cidr             = "10.0.0.0/16"
azs                  = ["ap-northeast-1a", "ap-northeast-1c"]
public_subnet_cidrs  = ["10.0.0.0/24", "10.0.1.0/24"]
private_subnet_cidrs = ["10.0.2.0/24", "10.0.3.0/24"]

#--------------------------------------------------------------
# RDS
#--------------------------------------------------------------

db_name     = "testdb"
db_username = "admin"