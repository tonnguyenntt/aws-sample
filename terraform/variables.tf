variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "keypair_name" {}
variable "keypair_public" {}

variable "aws_region" {
    description = "EC2 Region for the VPC"
    default = "ap-southeast-1"
}

variable "aws_availability_zone" {
    description = "Availability zone"
    default = "ap-southeast-1a"
}

variable "aws_instance_type" {
    description = "Instance type"
    default = "m1.small"
}

variable "aws_ami" {
    description = "Amazon Machine Image"
    default = "ami-0c998cc5d6ab582a2" # UltraServe CentOS 7.4 AMI NAT - 2018.03.3-0 x86_64 HVM GP2
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}

variable "subnet_cidr_public" {
    description = "CIDR for the Public subnet"
    default = "10.0.0.0/24"
}

variable "subnet_cidr_private" {
    description = "CIDR for the Private subnet"
    default = "10.0.1.0/24"
}
