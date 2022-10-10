#--------------------------------------------------------------
# RDS
#--------------------------------------------------------------
resource "aws_db_instance" "rds" {
    allocated_storage      = 10                                             # ストレージ容量(GB)
    storage_type           = "gp2"                                          # ストレージタイプ
    engine                 = var.engine                                     # データベースエンジン
    engine_version         = var.engine_version                             # データベースエンジンのバージョン
    instance_class         = var.db_instance                                # DBインスタンスタイプ
    identifier             = var.db_name                                    # RDSインスタンス名称
    username               = var.db_username                                # マスターDBユーザー名
    password               = var.db_password                                # マスターDBユーザーのパスワード
    skip_final_snapshot    = true                                           # 最終的な DBスナップショットを作成するか
    vpc_security_group_ids = [aws_security_group.rds-sg.id]                 # 関連付けるVPCセキュリティグループ
    db_subnet_group_name   = aws_db_subnet_group.rds-subnet-group.name      # DBサブネットグループ
}

#--------------------------------------------------------------
# Subnet group
#--------------------------------------------------------------
resource "aws_db_subnet_group" "rds-subnet-group" {
    name        = var.db_name                                               # サブネットグループ名称
    description = "rds subnet group for ${var.db_name}"                     # 説明
    subnet_ids  = var.pri_subnet_ids                                        # VPCサブネットID
}

#--------------------------------------------------------------
# Security group
#--------------------------------------------------------------
resource "aws_security_group" "rds-sg" {
    name        = "${var.app_name}-rds-sg"                                  # セキュリティグループ名称
    description = "RDS service security group for ${var.app_name}"          # 説明
    vpc_id      = var.vpc_id                                                # VPC ID
    
    ingress {
        from_port   = 3306
        to_port     = 3306
        protocol    = "tcp"
        cidr_blocks = ["10.0.0.0/16"]
    }
    
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    tags = {
        Name = "${var.app_name}-rds-sg"
    }
}