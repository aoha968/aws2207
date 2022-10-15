variable "app_name" {}

variable "vpc_id" {}

variable "pri_subnet_ids" {}

variable "db_name" {
    default = "testdb"
}

variable "db_username" {
    default = "admin"
}

variable "db_password" {
    default = "admin1234"
}

variable "engine" {
    default = "mysql"
}

variable "engine_version" {
    default = "8.0.28"
}

variable "db_instance" {
    default = "db.t2.micro"
}
