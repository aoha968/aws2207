variable "app_name" {}

variable "vpc_id" {}

variable "pub_subnet_ids" {}

variable "key_pair" {
    default = "RaiseTech-kadai"             # キーペアの名前
}

variable "ingress_config" {
    type = list(object({
        port        = string
        protocol    = string
        cidr_blocks = list(string)
    }))
    
    default = [
        {
            port        = 22
            protocol    = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        },
        {
            port        = 3306
            protocol    = "tcp"
            cidr_blocks = ["10.0.0.0/16"]
        }
    ]
    description = "list of ingress config"
}
