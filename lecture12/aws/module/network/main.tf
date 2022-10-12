#--------------------------------------------------------------
# VPC
#--------------------------------------------------------------
resource "aws_vpc" "vpc" {
    cidr_block           = var.vpc_cidr             # VPCのIPv4 CIDR ブロック
    instance_tenancy     = "default"                # VPCに起動されたインスタンスのテナンシー
    enable_dns_support   = true                     # VPCでDNSサポートを有効/無効
    enable_dns_hostnames = true                     # VPCでDNSホスト名を有効/無効

    tags = {
        Name = "${var.name}-vpc"
    }
}

#--------------------------------------------------------------
# Internet Gateway
#--------------------------------------------------------------
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id         # VPC ID

    tags = {
        Name = "${var.name}-igw"
    }
}

#--------------------------------------------------------------
# Public subnet
#--------------------------------------------------------------
resource "aws_subnet" "pub-sub" {
    count = length(var.pub_cidrs)
    
    vpc_id                  = aws_vpc.vpc.id                        # VPC ID
    cidr_block              = element(var.pub_cidrs, count.index)   # サブネットの CIDR ブロック
    availability_zone       = element(var.azs, count.index)         # サブネットが存在する必要があるアベイラビリティーゾーン
    map_public_ip_on_launch = true                                  # インスタンスの起動時にパブリック IP アドレスが割り当てられるかどうか
    
    tags = {
        Name = "${var.name}-pub-${element(var.azs, count.index)}"
    }
}

resource "aws_route_table" "pub-rtb" {
    vpc_id = aws_vpc.vpc.id                                         # VPC ID

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
    
    tags = {
        Name = "${var.name}-pub-rtb"
    }
}

resource "aws_route_table_association" "pub-rtb-as" {
    count = length(var.pub_cidrs)
    
    subnet_id      = element(aws_subnet.pub-sub.*.id, count.index)  # 関連付けを作成するためのサブネット ID
    route_table_id = aws_route_table.pub-rtb.id                     # 関連付けるルーティングテーブルの ID
}

#--------------------------------------------------------------
# Private subnet
#--------------------------------------------------------------
resource "aws_subnet" "pri-sub" {
    count = length(var.pri_cidrs)
    
    vpc_id            = aws_vpc.vpc.id                              # VPC ID
    cidr_block        = element(var.pri_cidrs, count.index)         # サブネットの CIDR ブロック
    availability_zone = element(var.azs, count.index)               # サブネットが存在する必要があるアベイラビリティーゾーン
    
    tags = {
        Name = "${var.name}-pri-${element(var.azs, count.index)}"
    }
}

resource "aws_route_table" "pri-rtb" {
    vpc_id = aws_vpc.vpc.id                                         # VPC ID

    route {
        cidr_block     = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat-gw.id
    }
    
    tags = {
        Name = "${var.name}-pri-rtb"
    }
}

resource "aws_route_table_association" "pri-rtb-as" {
    count = length(var.pri_cidrs)
    
    subnet_id      = element(aws_subnet.pri-sub.*.id, count.index)  # 関連付けを作成するためのサブネットID
    route_table_id = aws_route_table.pri-rtb.id                     # 関連付けるルーティングテーブルのID
}

#--------------------------------------------------------------
# NAT
#--------------------------------------------------------------
resource "aws_eip" "nat-eip" {
    vpc        = true
    depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat-gw" {
    allocation_id = aws_eip.nat-eip.id                              # ゲートウェイのElastic IPアドレスの割り当てID
    subnet_id     = aws_subnet.pub-sub[0].id                        # NATゲートウェイが配置されているサブネットのサブネットID
    depends_on    = [aws_internet_gateway.igw]
}
