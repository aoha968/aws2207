# -------------------------------------------------------------------------#
#  EC2 Instance Create
# -------------------------------------------------------------------------#
resource "aws_instance" "ec2" {
    ami                         = "ami-0f36dcfcc94112ea1"           # インスタンスに使用するAMI
    instance_type               = "t2.micro"                        # インスタンスタイプ
    subnet_id                   = var.pub_subnet_ids[0]             # VPCサブネットID
    associate_public_ip_address = "true"                            # パブリックIPアドレスを関連付けるか
    key_name                    = "${var.key_pair}"                 # キーペアのキー名
    vpc_security_group_ids      = [aws_security_group.ec2-sg.id]    # 関連付けるセキュリティグループID
    disable_api_termination     = false                             # EC2インスタンスの終了保護するか                        

    user_data = <<EOF
    #!/bin/bash
       sudo yum -y update
       sudo yum -y install mysql
       sudo yum -y install httpd
       sudo systemctl start httpd.service
       sudo systemctl enable httpd.service
    EOF

    tags = {
        Name = "ec2-instance"
    }
}

# -------------------------------------------------------------------------#
#  ElasticIP Create and Associate
# -------------------------------------------------------------------------#
resource "aws_eip" "ec2-eip" {
    vpc      = true
    instance = aws_instance.ec2.id
}

#--------------------------------------------------------------
# Security group
#--------------------------------------------------------------

resource "aws_security_group" "ec2-sg" {
    name = "${var.app_name}-ec2-sg"
    
    description = "EC2 service security group for ${var.app_name}"
    vpc_id      = var.vpc_id
    
    dynamic "ingress" {
        for_each = { for i in var.ingress_config : i.port => i }
        
        content {
            from_port   = ingress.value.port
            to_port     = ingress.value.port
            protocol    = ingress.value.protocol
            cidr_blocks = ingress.value.cidr_blocks
        }
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
